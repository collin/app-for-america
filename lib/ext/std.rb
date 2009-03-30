class Integer
  def tries attempt = 1, &block
    begin
      return block.call
    rescue Exception
      if attempt == self
        return false 
      else
        self.tries(attempt+1,  &block)
      end
    end    
  end
end

class Time
  def start_of_day
    self - self.hour.hours - self.min.minutes - self.sec.seconds
  end
  
  def end_of_day
    start_of_day + 1.day
  end
  
  def twitter_search_time
    start_of_day.strftime("%Y-%m-%d")
  end
  
  def js_time
    gmtime.strftime("%b, %d %Y %H:%M:%S GMT")
  end
end


