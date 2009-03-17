require 'rubygems'
require 'json'
require 'tempfile'
require 'pathname'
require 'shell'
require 'digest/md5'
require 'open4'

include Open4

module Dynomite
  DYNOMITE_DEFAULT_PATH = "/usr/local/dynomite"
  
  class Node
    
    attr_accessor :blocksize, :text_port
    attr_accessor :thrift_port, :web_port
    attr_accessor :directory, :storage_mod
    attr_accessor :q, :n, :w, :r
    attr_accessor :node_name
    attr_accessor :cluster_name
    attr_accessor :cache
    attr_accessor :cache_size
    attr_accessor :log_directory
    attr_accessor :install_path
    
    alias :partitioning_constant :q
    alias :replicas :n
    alias :write_constant :w
    alias :read_constant :r

    protected

    attr_reader :detached
    attr_reader :cookie
    attr_reader :install_path
    
    public
    
    # Each of these becomes an instance variable in the node object
    DEFAULT_JSON_CONFIG = { 
      :blocksize=>4096,
      :text_port=>11222,
      :thrift_port=>9200,
      :web_port=>8080,
      :directory=> %Q{/var/db/dynomite},
      :storage_mod=>%Q{dets_storage},
      :cache=>true,
      :cache_size=>128000,
      :r=>1,
      :w=>1,
      :n=>1,    
      :q=>6,
      :node_name=>%Q{dynomite_node},
      :cluster_name=>%Q{dynomite_cluster},
      :log_directory=>"",
    }

    def initialize(params={ })
      raise ArgumentError unless params.respond_to? :keys # Hash or Mash or something like it
      vars = self.class.default_config.merge! params
      
      @install_path = params[:dynomite_path]
      @install_path ||= Dynomite::DYNOMITE_DEFAULT_PATH
      @detached =  params[:detached]
      @cookie = nil
      
      DEFAULT_JSON_CONFIG.keys.each do |config_key|
        instance_variable_set("@#{config_key}".to_sym, vars[config_key])
      end
    end

    def start(join="")
      process_status = nil
      begin
        configfile = Tempfile.new("dynomite-config")
        configfile.puts to_json
        configfile.close
        
        @cookie = Digest::MD5.hexdigest(cluster_name + "NomMxnLNUH8suehhFg2fkXQ4HVdL2ewXwM")
        join_clause = join.empty? ? "" : "-dynomite jointo \"#{join}\""
        log_clause =  log_directory.empty? ? "" : %Q[-kernel error_logger '{file,"#{File.join(log_directory, 'dynomite.log')}"}' -sasl sasl_error_logger '{file,"#{File.join(log_directory, 'sasl.log')}"}']
        detach_clause  = self.detached.nil? ? "" : " -detached "
        
        commandline = %Q[erl -boot start_sasl +K true +A 128 +P 60000 -smp enable -pz #{install_path}/ebin/ -pz #{install_path}/deps/mochiweb/ebin -pz #{install_path}/deps/rfc4627/ebin -pz #{install_path}/deps/thrift/ebin -sname \"#{self.node_name}\" ] + join_clause + log_clause + %Q[ -dynomite config  "\\"#{configfile.path}\\"" -setcookie #{cookie} -noshell -run dynomite start ] + detach_clause
       #  #{options[:profile]}"

        stdin, stdout, stderr = '', '', ''
        process_status = spawn commandline, 'stdin' => stdin, 'stdout' => stdout, 'stderr' => stderr
        self
      rescue
        STDERR.puts "Start failed!: #{$!}, process status: #{process_status}"
      end
    end
    
    def stop
      raise ArgumentError if (node_name.nil? or node_name.empty? or cookie.nil?)
      process_status = nil
      begin
        commandline = %Q[erl -smp -sname console_#{$$} -hidden -setcookie #{cookie} -pa #{install_path}/ebin/ -run commands start -run erlang halt -noshell -node #{node_name}@#{`hostname -s`.chomp} -m init -f stop]
        stdin, stdout, stderr = '', '', ''
        process_status = spawn commandline, 'stdin' => stdin, 'stdout' => stdout, 'stderr' => stderr
      rescue
        STDERR.puts "Stop failed!: #{$!}, process status: #{process_status}"
      end
    end
    
    def leave
      str = %Q[erl -sname remsh_#{$$} -remsh #{node_name}@#{`hostname -s`.chomp} -hidden -setcookie #{cookie} -noshell -run membership leave) ]
    end
    
    def to_json(*a)
      instance_variables.inject({ }) { |memo,iv| memo[iv[1..-1].to_sym] = instance_variable_get(iv); memo}.to_json
    end

    class << self
      def default_config
        DEFAULT_JSON_CONFIG.clone
      end
    end
    
  end

end

