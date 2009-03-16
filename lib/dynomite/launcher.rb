require 'rubygems'
require 'json'
require 'tempfile'
require 'pathname'
require 'shell'

require 'dynomite/config'
require 'dynomite/node'

module Dynomite

  class Launcher
    
    @@DYNOMITE_PATH = "/usr/local/dynomite"

    attr_accessor :install_path

    def initialize(install_path=nil)
      @install_path = install_path
      @install_path ||= @@DYNOMITE_PATH
    end
    
    def start(config, join=nil)
      begin
        tf = Tempfile.new("dynomite-config")
        tf.puts config.to_json
        tf.close

        join_clause = join.nil? ? "" : "-j #{join}"
        log_directory = config.log_directory.empty? ? "" : "-l \"#{config.log_directory}\""
        commandline = "#{self.install_path}/bin/dynomite start #{join_clause} #{log_directory} -o #{config.node_name} -n #{config.cluster_name} --config #{tf.path} -d" 
        system(commandline)
        Node.new(:config=>config, :commandline=>commandline)
      rescue
        STDERR.puts "Start failed!: #{$!}"
      end
    end
    
    def stop(config)
      begin
        commandline = "#{self.install_path}/bin/dynomite stop -o #{config.node_name} -n #{config.cluster_name}"
        system(commandline)
      rescue
        STDERR.puts "Stop failed!: #{$!}"          
      end
    end

    def join(config)
      dc_slave = config.clone
      dc_slave.node_name+="_1"
      dc_slave.directory+="_1"
      dc_slave.text_port+=1
      dc_slave.thrift_port+=1
      dc_slave.web_port+=1

      node_to_join="#{config.node_name}@#{`hostname -s`.strip}"
      start(dc_slave,node_to_join)
    end

    def build_cluster(config_base)
    end

    class << self
      def list_all
        # Find the running dynomite processes:  
        pids = `ps axuwww | grep erl | grep dynomite | grep -v grep | cut -d ' ' -f 8`.split("\n").map { |pid| pid.to_i}
      end
      
      def kill_all
        # Find the running dynomite processes:  
        list_all.each do |pid|
          begin
            Process.kill("TERM", pid)
          rescue Errno::ESRCH
          end
        end
      end
      
    end
  end

end

if __FILE__ == $0
  puts JSON.pretty_generate(Opscode::DynomiteConfig.default_config)
  
  dc_master = Opscode::DynomiteConfig.new(:n=>3, :w=>2,
                                          :r=>1, :node_name=>'goober-master',
                                          :cluster_name=>'goober-cluster')
  nodes = [dc_master]
  
  (1..4).each do |node_number|
    conf = dc_master.clone.merge!( { :node_name=>"goober-#{node_number}", :text_port=>11222+node_number,
                                     :thrift_port=>9200+node_number, :web_port=>8080+node_number,
                                     :directory=>"/tmp/data#{node_number}"})
    nodes << Opscode::DynomiteConfig.new(conf)
  end

  # Nominate your own install path
  # DynomiteLauncher.install_path = "/Users/cb/Projects/dynomite"
  nodes.each_with_index { |n,index| Opscode::DynomiteLauncher.start(n, (index>0 && dc_master.node_name))}
  
  #DynomiteLauncher.stop pids

  nodes.each do |node|
    Opscode::DynomiteLauncher.stop(node)
  end

  nodes.each_with_index { |n,index| Opscode::DynomiteLauncher.start(n, (index>0 && dc_master.node_name))}
  
  Opscode::DynomiteLauncher.killall
end

