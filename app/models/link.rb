class Link
  include DataMapper::Resource
  
  property :id, Serial

  property :url, String,
    :length => 2000,
    :unique => true,
    :nullable => false

  property :page_title, String,
    :length => 80,
    :nullable => false

  property :page_content, Text,
    :nullable => false,
    :length => 65000
  
  has n, :tweets,   :through => Resource

  belongs_to :source
    
  before :valid? do
    return unless new_record?
    begin
      fetch_page_content
      return if page_content.blank?
      fetch_page_title
    rescue Exception
      nil
    end
  end
  
  def fetch_page_content
      opened_uri = open(Addressable::URI.heuristic_parse(url.strip))
      set_source(opened_uri.base_uri)
      self.page_content = opened_uri.read
  end

  def set_source uri
    host = uri.host
    self.source = Source.first(:host => host) || Source.create(:host => host)
  end
  
  def fetch_page_title
    title = (document/"title").inner_html
    self.page_title = if title.blank?
      url
    else
      title
    end
  end

  def page_title= title
    attribute_set(:page_title, Iconv.new('UTF-8//IGNORE', 'UTF-8').
      iconv("#{attribute_get(:page_title)} ")[0..-2])
  end

  def page_content= content
    attribute_set(
      :page_content, 
      Iconv.new('UTF-8//IGNORE', 'UTF-8').
        iconv(content)[0..-2]) 
  end

  def to_json *args
    {:page_title =>     page_title, :url => url}.to_json
  end
    
  
  def page_title= title
    title = title[0..75]if title.length > 80
    attribute_set :page_title, title
  end
  
  def document
    @document ||= Hpricot.parse page_content
  end
end
