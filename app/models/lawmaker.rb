class Lawmaker
  include DataMapper::Resource
   
  property :id, Serial
   
  property :bioguide_id, String
  property :congress_office, String,
    :length => 500
  property :crp_id, String
  property :district, Integer
  property :email, String,
    :length => 255
  property :fax, String
  property :fec_id, String
  
  property :firstname, String
  property :gender, Enum["M", "F"]
  property :lastname, String
  property :middlename, String
  property :nickname, String  
  property :party, String
  property :phone, String, :index => true
  property :senate_class, String
  property :name_suffix, String
  property :govtrack_id, String
  property :sunlight_old_id, String
  property :in_office, Integer
  property :eventful_id, String  
  property :state, String,
    :length => 1000
  property :title, String,
    :length => 1000
  property :twitter_id, String
  property :votesmart_id, String
  property :webform, URI,
    :length => 1000
  property :website, URI,
    :length => 1000
  property :youtube_url, URI,
    :length => 1000
  property :congresspedia_url, URI,
    :length => 1000
    
  property :tweetcongress_url, URI,
    :length => 1000
    
  has n, :lawmaker_tweets
  has n, :tweets, :through => :lawmaker_tweets,
    :mutable => true
  
  def first_and_last
    "#{firstname} #{lastname}"
  end
  
  def lastname_unique?
    false
  end
  
  def mentioned_in tweet
    return if lawmaker_tweets.first(:tweet_id => tweet.id)
    LawmakerTweet.create :lawmaker_id => id, :tweet_id => tweet.id
  end
  
  def twitter_query
    query = %{"#{first_and_last}"} 
    query << %{ OR "#{twitter_id}"} unless twitter_id.blank?
#    query << %{ OR "#{nickname}"}   unless nickname.blank?
    query << %{ OR "#{lastname}"}   if lastname_unique?
    query
  end

  def placard
    "#{title} #{firstname} #{lastname}"
  end
  
  def twitters?
    not twitter_id.blank?
  end

  def self.create_from_sunlight_legistor legislator
    lawmaker = new
    legislator.instance_variables.each do |var|
      var.gsub! '@', ''
      lawmaker.send "#{var}=", legislator.send(var)
    end
    lawmaker.save
  end
  
  def self.create_from_sunlight_legislators
    Sunlight::Legislator.all_where(:in_office => 1).each do |legislator|
      create_from_sunlight_legistor legislator
    end
  end
end
