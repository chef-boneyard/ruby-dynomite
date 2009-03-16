require 'rubygems'
require 'json'
require 'tempfile'
require 'pathname'
require 'shell'

require 'dynomite/config'

module Dynomite

  class Node

    def initialize(config)
      @config = config
    end
    
  end
  
end
