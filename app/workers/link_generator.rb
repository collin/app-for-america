class LinkGenerator < Workling::Base

  def generate_links options
    Tweet.get(options[:tweet_id]).generate_links
  end
  
end
