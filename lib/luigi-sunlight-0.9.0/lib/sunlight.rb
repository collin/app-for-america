require 'rubygems'
require 'json'
require 'cgi'
require 'ym4r/google_maps/geocoding'
require 'net/http'
include Ym4r::GoogleMaps

# Dir["#{File.dirname(__FILE__)}/sunlight/*.rb"].each { |source_file| require source_file }
%w{base.rb  district.rb  filing.rb  issue.rb  legislator.rb  lobbyist.rb}.each do |file|
  require "#{File.dirname(__FILE__)}/sunlight/#{file}"
end
