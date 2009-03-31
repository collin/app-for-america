class TweetFetcher < Workling::Base
  def fetch_tweets options
    Twitter::Search.one_day_search options[:subject], options[:day]
  end

  def self.full_historical_search_all id=0
    while(lawmaker = Lawmaker.first(:id.gt => id)) do
      full_historical_search lawmaker
      id = lawmaker.id
    end
  end
  
  def self.full_historical_search lawmaker
   90.times do |number_of|
      day = number_of.days.ago
      next if lawmaker.tweets.for_day(day).count > 0
      TweetFetcher.async_fetch_tweets :subject => lawmaker, :day => day
    end
  end  
end
