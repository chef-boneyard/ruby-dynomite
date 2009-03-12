require 'rubygems'
require 'thrift'
require 'thrift/transport/tsocket'
require 'thrift/protocol/tbinaryprotocol'
require "gen-rb/Dynomite"


class DynomiteClient
  @configuration = { :host=>'localhost', :port=>9200, :transport=>Thrift::TBufferedTransport, :protocol=>Thrift::TBinaryProtocol }
  def connect
    @socket = Thrift::TSocket.new(Dynomite::Config[:host], Dynomite::Config[:port])
    @socket.open
    @protocol = Dynomite::Config[:protocol].new(Dynomite::Config[:transport].new(socket))
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

