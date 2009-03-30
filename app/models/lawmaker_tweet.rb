class LawmakerTweet
  include DataMapper::Resource
  
  property :lawmaker_id, Integer, 
    :key => true,
    :nullable => false
  
  property :tweet_id, Integer, 
    :key => true,
    :nullable => false
  
  belongs_to :lawmaker
  belongs_to :tweet
end
