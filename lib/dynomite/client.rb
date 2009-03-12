require 'rubygems'
require 'thrift'
require 'thrift/transport/tsocket'
require 'thrift/protocol/tbinaryprotocol'

require 'dynomite/config'
require 'dynomite/launcher'

$:.unshift(File.join(File.dirname(__FILE__), "..", "gen-rb"))
require "Dynomite.rb"

class DynomiteClient

  attr_reader :config
  protected :config
  
  def initialize(params={ })
    @config = { :host=>'localhost', :port=>9200, :transport=>Thrift::TBufferedTransport, :protocol=>Thrift::TBinaryProtocol }.merge(params)
  end

  def connect
    @socket = Thrift::TSocket.new(config[:host], config[:port])
    @socket.open
    @protocol = config[:protocol].new(config[:transport].new(@socket))
    @client = Dynomite::Client.new(protocol)
  end

  def disconnect
    @socket.close unless @socket.nil? or !@socket.opened?
  end

  def get
  end

  def put(value)
  end
end

if $0 == __FILE__
  client.put("a key", nil, "a value")
  get_result = client.get("a key")
  puts "Result context '#{get_result.context}'"
  puts "Result value #{get_result.results}"
end

