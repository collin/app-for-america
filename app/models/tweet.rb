class Tweet
  include DataMapper::Resource
  
  property :id, Serial

  property :id, Integer, 
    :key => true

  property :text, String,
    :length => 4000
  
  property :to_user_id, Integer
  property :to_user, String
  
  property :from_user_id, Integer
  property :from_user, String
  
  property :profile_image_url, String,
    :length => 400
    
  property :created_at, DateTime
  
  property :source, String,
    :length => 4000,
    :default => "&lt;a href=&quot;http://twitter.com&quot;&gt;web&lt;/a&gt;"
  
  property :iso_language_code, Text

  has n, :lawmaker_tweets
  has n, :lawmakers, :through => :lawmaker_tweets

  has n, :links, :through => Resource

  after :create, :schedule_link_generation

  def self.latest
    first :order => [:id.desc]
  end  

  def matched_urls
    return @matched_urls if @matched_urls
    match = text.match(/(http:\/\/.*?) |(http:\/\/.*?)$/)
    return @matched_urls = [] unless match
    @matched_urls = match.captures.compact.map  do |url|
      url.gsub /\(|\)/, ''
    end
  end
  
  def schedule_link_generation
    LinkGenerator.async_generate_links :tweet_id => self.id
  end
  
  def generate_links
    matched_urls.each do |match| 
      begin
        link = Link.first(:url => match) || Link.create(:url => match)
        self.links << link unless self.links.include?(link)
      rescue OpenURI::HTTPError => e
        # Oh well, bad link.
      end
    end
    save
  end
  
  def created_at= time
    attribute_set :created_at, Time.parse(time)
  end
  
  def self.for_day time
    Tweet.all(
      :created_at.gte => time.start_of_day, 
      :created_at.lte => time.end_of_day)
  end


  def reply_url
    Addressable::URI.encode "http://twitter.com/home?status=@#{from_user} #{text}&in_reply_to_status_id=#{id}&in_reply_to=#{from_user}"
  end

  def from_user_url
    "http://twitter.com/#{from_user}"
  end

  def status_url
    "http://twitter.com/#{from_user}/status/#{id}"
  end
end
