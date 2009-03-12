require 'rubygems'
require 'json'
require 'tempfile'
require 'pathname'
require 'shell'

class DynomiteConfig
  
  attr_accessor :blocksize, :text_port
  attr_accessor :thrift_port, :web_port
  attr_accessor :directory, :storage_mod
  attr_accessor :partitioning_constant, :number_of_nodes
  attr_accessor :write_constant, :read_constant
  attr_accessor :node_name, :cluster_name

  DEFAULT_CONFIG = { 
    :blocksize=>4096,
    :text_port=>11222,
    :thrift_port=>9200,
    :web_port=>8080,
    :directory=> %Q{/tmp/data},
    :storage_mod=>%Q{dets_storage},
    :number_of_nodes=>1,
    :read_constant=>1,
    :write_constant=>1,
    :partitioning_constant=>6,
    :node_name=>%Q{dynomite_node},
    :cluster_name=>%Q{dynomite_cluster},
  }

  def initialize(params={ })
    raise ArgumentError unless params.respond_to? :keys # Hash or Mash or something like it
    vars = self.class.default_config.merge! params
    DEFAULT_CONFIG.keys.each do |config_key|
      instance_variable_set("@#{config_key}".to_sym, vars[config_key])
    end
  end
  
  class << self
    def default_config
      DEFAULT_CONFIG.clone
    end
  end

  def to_json(*a)
    JSON.pretty_generate instance_variables.inject({ }) { |memo,iv| memo[iv[1..-1].to_sym] = instance_variable_get(iv); memo}
  end
end

