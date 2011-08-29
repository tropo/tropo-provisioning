
class TropoClient
  
  attr_accessor :headers
  attr_reader :base_uri
  attr_reader :username
  attr_reader :password
  
  def initialize(base_uri = "http://api.tropo.com/v1", username, password, headers)
    @base_uri = base_uri
    @username = username
    @password = password
    @headers = headers.nil? ? {} : headers
  end
  
  def request(method, params = {})
    params[:body] and params[:body] = camelize_params(params[:body])
    
    uri = params[:resource].nil? ? "" : params[:resource]

    request = set_request_type(method, base_uri+uri)
    request.initialize_http_header(headers)
    request.basic_auth username, password
    request.body = ActiveSupport::JSON.encode params[:body] if params[:body]
    
    begin
      response = http.request(request)
    rescue => e
      raise RuntimeError, "Unable to connect to the Provisioning API server - #{e.to_s}"
    end

    response.code.eql?('200') or raise TropoError.new(response.code), "#{response.code}: #{response.message} - #{response.body}"
    
    result = ActiveSupport::JSON.decode response.body
    if result.instance_of? Array
      self.class.hashie_array(result)
    else
      Hashie::Mash.new(result)
    end    
  end
  
  ##
  #
  def camelize_params(params)
    camelized = {}
    params.each { |k,v| camelized.merge!(k.to_s.camelize(:lower).to_sym => v) }
    camelized
  end
  
  
  ##
  # Sets the HTTP REST type based on the method being called
  # 
  # @param [required, ymbol] the HTTP method to use, may be :delete, :get, :post or :put
  # @param [Object] the uri object to create the request for
  # @return [Object] the request object to be used to operate on the resource
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
  
  def http
    @http ||= (
      uri = URI.parse(base_uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      http
    )
  end
  
  class << self
    ##
    # Converts the hashes inside the array to Hashie::Mash objects
    #
    # @param [required, Array] array to be Hashied
    # @param [Array] array that is now Hashied
    def hashie_array(array)
      hashied_array = []
      array.each do |ele|
        hashied_array << Hashie::Mash.new(ele)
      end
      hashied_array
    end
  end
  
  
  
end