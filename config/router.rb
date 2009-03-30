Merb.logger.info("Compiling routes...")
Merb::Router.prepare do
  # Adds the required routes for merb-auth using the password slice
  slice(:merb_auth_slice_password, :name_prefix => nil, :path_prefix => "")

  resources :lawmakers
end
