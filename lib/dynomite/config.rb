require 'rubygems'
require 'json'
require 'tempfile'
require 'pathname'
require 'shell'

module Dynomite

  class Config
    
    attr_accessor :blocksize, :text_port
    attr_accessor :thrift_port, :web_port
    attr_accessor :directory, :storage_mod
    attr_accessor :q, :n, :w, :r
    attr_accessor :node_name
    attr_accessor :cluster_name
    attr_accessor :cache
    attr_accessor :cache_size
    
    alias :partitioning_constant :q
    alias :number_of_nodes :n
    alias :write_constant :w
    alias :read_constant :r

    DEFAULT_JSON_CONFIG = { 
      :blocksize=>4096,
      :text_port=>11222,
      :thrift_port=>9200,
      :web_port=>8080,
      :directory=> %Q{/tmp/data},
      :storage_mod=>%Q{dets_storage},
      :cache=>true,
      :cache_size=>128000,
      :r=>1,
      :w=>1,
      :n=>1,    
      :q=>6,
      :node_name=>%Q{dynomite_node},
      :cluster_name=>%Q{dynomite_cluster},
    }

    def initialize(params={ })
      raise ArgumentError unless params.respond_to? :keys # Hash or Mash or something like it
      vars = self.class.default_config.merge! params
      DEFAULT_JSON_CONFIG.keys.each do |config_key|
        instance_variable_set("@#{config_key}".to_sym, vars[config_key])
      end
    end
    
    class << self
      def default_config
        DEFAULT_JSON_CONFIG.clone
      end
    end

    def to_json(*a)
      instance_variables.inject({ }) { |memo,iv| memo[iv[1..-1].to_sym] = instance_variable_get(iv); memo}.to_json
    end
  end

end
