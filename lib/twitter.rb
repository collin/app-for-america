class Twitter
  class Search
    include HTTParty
    
    PerPage = 100
    Sanity  = 10_000
    
    base_uri 'search.twitter.com/search.json'
    format :json
    
    default_params :lang => :en,
      :rpp => PerPage
      
#    def self.full_historical_search subject
#      90.times do |number_of|
#        day = number_of.days.ago
#        next if subject.tweets.for_day(day).count > 0
#        one_day_search subject, day
#      end
#    end
    
    def self.one_day_search subject, day
      tweets = self.find_for_day(subject, day)
      tweets.each do |result|
        unless (tweet = Tweet.get(result["id"]))
          tweet = Tweet.create(result)
        end
        subject.mentioned_in tweet
      end
    end
    
    def self.find_for_day subject, day
      tweets = []
      continue = true
      page = 1
      while continue do
        page_tweets = 4.tries{self.paged_for_day(subject, day, page)} || []
        continue = false if page_tweets.empty?
        continue = false unless page_tweets.length == PerPage
        tweets += page_tweets
        page   += 1
      end
      tweets
    end
    
    def self.paged_for_day subject, day, page
      payload = {
        :q     => subject.twitter_query,
        :since => day.start_of_day.twitter_search_time,
        :until => day.end_of_day.twitter_search_time,
        :page  => page
      }
      
      last_for_day = subject.tweets.for_day(day+1.day).latest
      payload[:since_id] = last_for_day.id if last_for_day
      results = get('', :query => payload)["results"]
      results
    end
  end
end
