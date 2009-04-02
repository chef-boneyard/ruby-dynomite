#
# Author:: Christopher Brown <cb@opscode.com>
#
# Copyright 2009, Opscode, Inc.
#
# All rights reserved - do not redistribute
#

require 'rubygems'
require 'mixlib/config'

module Dynomite
  class Config
    extend Mixlib::Config
    
    log_level :fatal
    log_location STDOUT
  
  end
end


