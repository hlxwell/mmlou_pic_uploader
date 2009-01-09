Dir.glob(File.join(File.dirname(__FILE__), '../lib/*.rb')).each do |f|
  require f unless f =~ /main.rb/
end

#require File.dirname(__FILE__)+'/../lib/filefinder'
#require File.dirname(__FILE__)+'/../lib/album'
#require File.dirname(__FILE__)+'/../lib/uploader'

require 'test/unit'
require 'rubygems'
require 'shoulda'
require 'mocha'