require 'rubygems'
require 'json'
require 'tempfile'
require 'pathname'
require 'shell'

class DynomiteLauncher
  
  @dynomite_path = "/usr/local/dynomite"
  
  class << self
    def install_path
      @dynomite_path
    end
    
    def install_path=(value)
      @dynomite_path = value
    end
    
    def start(config, join=false)
      begin
        tf = Tempfile.new("dynomite-config")
        tf.puts config.to_json
        tf.close
        pn = Pathname.new(tf.path)
        config_dir = pn.dirname
        config_filename = pn.basename
        
        Shell.new.pushd(config_dir) do
          commandline = "#{self.install_path}/bin/dynomite" + " start -d " + (join ? "-j #{join}" : "") + " -o #{config.node_name} -n #{config.cluster_name} --config #{config_filename}" 
          STDERR.puts "launching... #{commandline}"
          system(commandline)
        end
        
      rescue
        STDERR.puts "Start failed!: #{$!}"
      end
    end
    
    def stop(config)
      begin
        commandline = "#{self.install_path}/bin/dynomite stop -o #{config.node_name} -n #{config.cluster_name}"
        STDERR.puts "stopping... #{commandline}"
        system(commandline)
      rescue
        STDERR.puts "Stop failed!: #{$!}"          
      end
    end
    
    def killall
      # Find the running dynomite processes:  
      pids = `ps axuwww | grep erl | grep dynomite | grep -v grep | cut -d ' ' -f 8`.split("\n").map { |pid| pid.to_i}
      pids.each do |pid|
        begin
          Process.kill("TERM", pid)
        rescue Errno::ESRCH
        end
      end
    end

  end
end


if __FILE__ == $0
  puts JSON.pretty_generate(Opscode::DynomiteConfig.default_config)
  
  dc_master = Opscode::DynomiteConfig.new(:number_of_nodes=>3, :write_constant=>2,
                                          :read_constant=>1, :node_name=>'goober-master',
                                          :cluster_name=>'goober-cluster')
  nodes = [dc_master]
  
  (1..4).each do |node_number|
    nodes << Opscode::DynomiteConfig.new({ :node_name=>"goober-#{node_number}", :text_port=>11222+node_number,
                                           :thrift_port=>9200+node_number, :web_port=>8080+node_number,
                                           :directory=>"/tmp/data#{node_number}", :cluster_name=>'goober-cluster'})
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

