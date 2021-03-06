# Go to http://wiki.merbivore.com/pages/init-rb
 
require 'config/dependencies.rb'
 
use_orm :datamapper
use_test :rspec
use_template_engine :haml
 
Merb::Config.use do |c|
  Merb::Config[:secrets] = YAML.load(File.read(Merb.root/'config/secrets.yml'))
  c[:use_mutex] = false
  c[:session_store] = 'cookie'  # can also be 'memory', 'memcache', 'container', 'datamapper
  
  c[:secrets] = YAML.load(File.read(Merb.root/'config/secrets.yml'))
  # cookie session store configuration
  c[:session_secret_key]  = c[:secrets][:session]  # required for cookie session store
  c[:session_id_key] = '_app_for_america_session_id' # cookie session id key, defaults to "_session_id"  

  c[:compass] = {
    :stylesheets => 'app/stylesheets',
    :compiled_stylesheets => 'public/stylesheets/compiled'
  }
end
 
Merb::BootLoader.before_app_loads do

  require Merb.root/'lib/ext/std'
  Dir.glob(Merb.root/'lib/*.rb').each{|lib| require lib } 
  Dir.glob(Merb.root/'lib/*.rb').each{|lib| require lib }
  
  require Merb.root/'plugins/workling/lib/workling/base'
  require Merb.root/'plugins/workling/lib/workling/discovery'
end
 
Merb::BootLoader.after_app_loads do
  $LOAD_PATH << Merb.root/'plugins/workling/lib'
  require Merb.root/'plugins/workling/lib/workling'
  require Merb.root/'plugins/workling/lib/workling/base'
  require Merb.root/'plugins/workling/lib/workling/discovery'
  require Merb.root/'plugins/workling/lib/workling/remote/invokers/basic_poller'
  require Merb.root/'plugins/workling/lib/workling/remote/invokers/threaded_poller'
  require Merb.root/'plugins/workling/lib/workling/remote/invokers/eventmachine_subscriber'
  require Merb.root/'plugins/workling/lib/workling/routing/class_and_method_routing'
  require Merb.root/'plugins/workling/lib/workling/remote'
  require Merb.root/'plugins/workling/init'

  Dir.glob(Merb.root/'app/workers/*.rb').each{|lib| require lib }
  Merb::Config[:secrets] = YAML.load(File.read(Merb.root/'config/secrets.yml'))
  Sunlight::Base.api_key = Merb::Config[:secrets][:sunlight]
  class Calais; def license_id; Merb::Config[:secrets][:calais] end end
end
