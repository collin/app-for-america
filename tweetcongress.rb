states = Hpricot.parse open("http://tweetcongress.org/officials/states").read

state_pages = (states/"ol.stats:first a").map{|state| state[:href] }

state_pages.each do |url|
  state_page = Hpricot.parse open("http://tweetcongress.org"+url).read
  (state_page/'.rep').each do |rep|
    lawmaker = Lawmaker.first(:phone  => (rep/'.phone:first').text.strip)
    next unless lawmaker
    
    lawmaker.tweetcongress_url = "http://tweetcongress.org" + ((rep/'.rep-name a:first').first[:href])
    
    twitter_id = (rep/'.twitter-username')
    
    if lawmaker.twitter_id.blank?
      lawmaker.twitter_id = twitter_id.text if twitter_id
    end
    
    lawmaker.save
  end
end

