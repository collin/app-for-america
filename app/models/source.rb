class Source
  include DataMapper::Resource
  
  property :id, Serial

  property :host, String, :length => 1000,
    :nullable => false,
    :unique => true
end
