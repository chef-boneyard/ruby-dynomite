require 'rubygems'
require 'thrift'
require 'thrift/transport/tsocket'
require 'thrift/protocol/tbinaryprotocol'

require 'dynomite/node'

$:.unshift(File.join(File.dirname(__FILE__), "..", "thrift"))
require 'Dynomite.rb'

module Dynomite

  class Client < DynomiteInternal::Client

    attr_reader :config
    protected :config
    
    def initialize(params={ })
      @config = { :host=>'localhost', :port=>9200, :transport=>Thrift::TBufferedTransport, :protocol=>Thrift::TBinaryProtocol }.merge(params)
      @socket = Thrift::TSocket.new(config[:host], config[:port])
      @protocol = config[:protocol].new(config[:transport].new(@socket))
      super(@protocol)
    end

    def connect
      @tcp_socket = @socket.open
      self
    end

    def disconnect
      @tcp_socket.close unless @tcp_socket.nil? or @tcp_socket.closed?
    end

  end

end
