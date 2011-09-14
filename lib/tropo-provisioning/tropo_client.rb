require 'active_support'
require 'active_support/json'
require 'hashie'
require 'net/http'
require 'net/https'
require 'uri'

# This class is in charge of handling HTTP requests to the Tropo HTTP endpoint
class TropoClient
  
  autoload :TropoError, 'tropo-provisioning/tropo_error'

  # required HTTP headers
  attr_accessor :headers
  # Tropo provisioning API endpoint
  attr_reader :base_uri
  # Valid Tropo username
  attr_reader :username
  # password associated to :username
  attr_reader :password
  
  ##
  # Creates a new TropoClient instance
  #
  # ==== Parameters
  # * [required, String] *username* valid Tropo username
  # * [required, String] *password* valid password
  # * [optional, String] *base_uri* Tropo provisioning API endpoint
  # * [optional, String] *headers* required HTTP headers
  #
  # ==== Return
  # * new TropoClient instance
  def initialize(username, password, base_uri = "http://api.tropo.com/v1/", headers)
    @base_uri = base_uri
    @base_uri[-1].eql?("/") or @base_uri << "/"
    @username = username
    @password = password
    @headers = headers.nil? ? {} : headers
  end
  
  ##
  # Send a HTTP Get
  #
  # ==== Parameters
  # * [optional, String] path URI
  # * [optional, Hash] Query parameters
  #
  # ==== Return
  # JSON decoded object
  def get(resource = "", params = {})
    uri = "#{base_uri}#{resource}"
    params.empty? or uri = uri.concat('?').concat(params.collect { |k, v| "#{k}=#{v.to_s}" }.join("&"))
    request(Net::HTTP::Get.new(uri))
  end
  
  ##
  # Send a HTTP Post
  #
  # ==== Parameters
  # * [optional, String] resource path URI
  # * [optional, Hash] params body to be JSON encoded
  #
  # ==== Return
  # JSON decoded object
  def post(resource = "", params = {})
    uri = "#{base_uri}#{resource}"
    request(Net::HTTP::Post.new(uri), params)
  end
  
  ##
  # Send a HTTP Delete
  #
  # ==== Parameters
  # * [optional, String] resource path URI
  # * [optional, Hash] Query parameters
  #
  # ==== Return
  # JSON decoded object
  def delete(resource = "", params = {})
    uri = "#{base_uri}#{resource}"
    params.empty? or uri = uri.concat('?').concat(params.collect { |k, v| "#{k}=#{v.to_s}" }.join("&"))
    request(Net::HTTP::Delete.new(uri))
  end

  ##
  # Send a HTTP Put
  #
  # ==== Parameters
  # * [optional, String] resource path URI
  # * [optional, Hash] params body to be JSON encoded
  #
  # ==== Return
  # JSON decoded object
  def put(resource = "", params = {})
    uri = "#{base_uri}#{resource}"
    request(Net::HTTP::Put.new(uri), params)
  end

  ##
  # Format the parameters
  #
  # ==== Parameters
  # * [required, Hash] request parameters
  # ==== Return
  # * camelized params
  def camelize_params(params)
    camelized = {}
    params.each { |k,v| camelized.merge!(k.to_s.camelize(:lower).to_sym => v) }
    camelized
  end
  
  
  ##
  # Sets the HTTP REST type based on the method being called
  # 
  # ==== Parameters
  # * [required, ymbol] the HTTP method to use, may be :delete, :get, :post or :put
  # * [Object] the uri object to create the request for
  # * [Object] the request object to be used to operate on the resource
  #
  # ==== Return
  # * Valid HTTP verb instance
  def set_request_type(method, uri)
    case method
    when :delete
      Net::HTTP::Delete.new(uri)
    when :get
      Net::HTTP::Get.new(uri)
    when :post
      Net::HTTP::Post.new(uri)
    when :put
      Net::HTTP::Put.new(uri)
    end
  end

  private
  
  ##
  # Creates (one once) a HTTP client to the Tropo provisioning endpoint
  #
  # ==== Return
  # * Net::HTTP instance
  def http
    @http ||= (
      uri = URI.parse(base_uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      http
    )
  end
  
  ##
  # Send a request to the Tropo provisioning API
  #
  # ==== Parameters
  # * [required, Symbol] http_request Net::HTTPRequest child
  # * [required, Hash] body details parameters to use when posting or putting an object, converts into the appropriate JSON
  #
  # ==== Return
  # * [Hash] the result of the request
  # * [TropoError]
  #   if it can not connect to the API server or if the response.code is not 200 
  def request(http_request, body = {})

    unless http_request.is_a?(Net::HTTPRequest)
      raise TropoError.new("Invalid request type #{http_request}")
    end
    
    http_request.initialize_http_header(headers)
    http_request.basic_auth username, password

    # Include body if received
    body.empty? or http_request.body = ActiveSupport::JSON.encode(body) 

    begin
      response = http.request(http_request)
    rescue => e
      raise TropoError.new, "Unable to connect to the Provisioning API server - #{e.to_s}"
    end

    response.code.eql?('200') or raise TropoError.new(response.code), "#{response.code}: #{response.message} - #{response.body}"
    
    result = ActiveSupport::JSON.decode response.body
    if result.instance_of? Array
      self.class.hashie_array(result)
    else
      Hashie::Mash.new(result)
    end    
  end

  class << self
    ##
    # Converts the hashes inside the array to Hashie::Mash objects
    #
    # ==== Parameters
    # * [required, Array] array to be Hashied
    #
    # ==== Return
    # * [Array] array that is now Hashied
    def hashie_array(array)
      hashied_array = []
      array.each do |ele|
        hashied_array << Hashie::Mash.new(ele)
      end
      hashied_array
    end
  end
  
end