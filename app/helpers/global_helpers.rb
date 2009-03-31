module Merb
  module GlobalHelpers
    def required_field label, klass=nil, type='text_field', options={}, &blk
      if options.has_key? :class
        options[:class] += ' required'
      else
        options[:class] = 'required'
      end
      field label, klass, type, options, &blk
    end
    
    def field label, klass=nil, type='text_field', options={}, &blk
      
      if Merb.env == "development"
        unless block_given?
          Merb.logger.warn "Field Without Instructions Block"
          Merb.logger.warn caller.grep(/html_haml/).join("\n")
        end
      end
      
      instructions = if block_given?
%{<div class="instructions">
    #{capture(&blk) if block_given?}
  </div>} 
      end


      context_object = current_form_context.instance_variable_get :@obj
      errors = unless context_object.nil?
        unless context_object.errors[klass].nil?
%{<ul class="errors">
  #{context_object.errors[klass].map{|msg| "<li>#{msg}</li>\n"}}
</ul>}
        end
      end
         
      markup = %{
<div class="meta_wrap #{(!context_object.nil? && !context_object.errors[klass].nil?) ? 'has_errors' : ''}">
  <div class="field_wrap #{options[:class]}">
    <div class="#{klass}">
      <div class="label-wrap">
        <label for="#{klass}">
          #{label}
          <em>
            #{"(required)" if options[:class] && options[:class].match(/required/)}
          </em>
        </label>
      </div>}
        field = send type, klass, options unless klass.nil?
%{
#{markup}
      #{field}
    </div>
  </div>
  #{if errors or instructions 
  %{<div class="meta">
    #{errors}
    #{instructions}
  </div>}
  end}
</div>
}
    end


    # three message styles: success, notice, error. thx compass!
    def show_message _type
      "<div class=\"#{_type}\">#{h message[_type]}</div>" if message[_type]
    end
    
    def button_link text, anchor, method='get'
      form_for(nil, :method => method, :action => anchor, :class => :button) do
      %{
        <button>
          <a href="#{anchor}">#{text}</a>
        </button>
      }      
      end
    end
    
    def interpret_tweet tweet, highlight=""
#      highlight.split(/ /).each do |part|
#        tweet.gsub!(part) do |match|
#          %{<span class="match">#{match}</span>}
#        end
#      end
    
      tweet.
        gsub(/(http:\/\/.*?) |(http:\/\/.*?)$/) do |match|
          link_to(
            match,
            match,
            :target => :_blank
          )
        end.
        gsub(/(#.*?) |(#.*?)$/) do |match| 
          link_to(
            match, 
            "http://search.twitter.com/search?q=#{URI.escape match}",
            :target => :_blank)
        end.
        gsub(/(@.*?) |(@.*?)$/) do |match| 
          link_to match, "http://twitter.com/#{match.gsub('@','')}", :target => :_blank
        end
    end

    def link_to anchor_text, href, options={}
      if request.uri[href]
        options[:class] ? options[:class] += " current" : options[:class] = "current"
      end
      super anchor_text, href, options
    end
    
    def chart_image_tag
      chart_url = File.read('chart_url')
      width, height = chart_url.match(/&chs=([\d]+x[\d]+)&/).captures.first.split /x/
      image_tag chart_url, 
        :alt    =>  "Chart of Number of tweets per-candidate over the past two weeks.",
        :width  => width,
        :height => height
    end
    
    def _include file
      if File.exist?(Merb.root/'views/includes/#{file}.html')
        File.read(Merb.root/'views/includes/#{file}.html')
      end
    end
    
    def analytics
      if Merb.env == 'production'
      %{   
<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
try {
var pageTracker = _gat._getTracker("UA-248270-14");
pageTracker._trackPageview();
} catch(err) {}</script>
}
      end
    end
  end
end
