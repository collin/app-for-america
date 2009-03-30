class Calais
  attr_accessor :hierarchy, :response
  
  class ContentLengthError < ArgumentError; end
  
  def license_id
    raise "You MUST define the method Calais.license_id to 
           return the string of your Calais License ID"
  end

  def initialize content, options={}
    @content, @options = content[0..99_999], options
    verify_content_length
    fetch_response
  end

  def verify_content_length
    unless @content.length > 100 && @content.length < 100_000
      raise ContentLengthError, "Unnacceptable content size, must be within [100..100_000]"
    end
  end

  def encoded_license
    encoded license_id
  end

  def content
    encoded @content
  end
  
  def content_type
    @options[:content_type] || "TEXT/HTML"
  end
  
  def output_format
    'application/json'
  end
  
  def params
    encoded construct_params
  end

  def construct_params
    Haml::Engine.new(params_haml).render(self)
  end

  def params_haml
%{
%c:params{'xmlns:c' => 'http://s.opencalais.com/1/pred/', 'xmlns:rdf' => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'}
  %c:processingDirectives{'c:enableMetadateType' => 'GenericRelations', 'c:contentType' => content_type, 'c:outputFormat' => output_format}
  %c:userDirectives
  %c:externalMetadata
}
  end

  def encoded text
    text
  end

  def endpoint
    Addressable::URI.parse "http://api.opencalais.com/enlighten/rest/"
  end
  
  def fetch_response
    response = Net::HTTP.post_form(
      endpoint,
      :licenseId => license_id, 
      :content => content, 
      :paramsXML => params)
      
    @response = JSON.parse response.body
    resolve_references
    create_hierarchy
  end
  
  def create_hierarchy
    @hierarchy = hdb = {}
    @response.each do |key, element|
      type = element["_type"]
      group = element["_typeGroup"]
      if group
        hdb[group] ||= {}
        if type
          hdb[group][type] ||= {}
          hdb[group][type][key] = element
        else
          hdb[group][key] = element
        end
      else
        hdb[key] = element
      end
    end
    hdb
  end
  
  def resolve_references
    @response.each do |key, element|
      element.each do |attribute, value|
        if value.is_a?(String) && @response[attribute]
          @response[key][attribute] = @response[attribute]
        end
      end
    end
  end
  
  def [] key
    @hierarchy[key]
  end
end
