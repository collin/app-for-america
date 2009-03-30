# Go to http://wiki.merbivore.com/pages/init-rb
 
require 'config/dependencies.rb'
 
use_orm :datamapper
use_test :rspec
use_template_engine :haml
 
Merb::Config.use do |c|
  c[:secrets] = YAML.load(File.read(Merb.root/'config/secrets.yml'))
  c[:use_mutex] = false
  c[:session_store] = 'cookie'  # can also be 'memory', 'memcache', 'container', 'datamapper
  
  # cookie session store configuration
  c[:session_secret_key]  = c[:secrets][:session]  # required for cookie session store
  c[:session_id_key] = '_app_for_america_session_id' # cookie session id key, defaults to "_session_id"  
end
 
Merb::BootLoader.before_app_loads do
  Dir.glob(Merb.root/'lib/*.rb').each{|lib| require lib } 
  Dir.glob(Merb.root/'lib/*.rb').each{|lib| require lib }  
end
 
Merb::BootLoader.after_app_loads do
  Sunlight::Base.api_key = Merb::Config[:secrets][:sunlight]
  class Calais; def license_id; Merb::Config[:secrets][:calais] end end
end
