class TropoProvisioning
  
  # Defaults for the creation of applications
  DEFAULT_OPTIONS = { :partition => 'staging', :platform  => 'scripting' }
  ##
  # Creates a new TropoProvisioning object
  #
  # @param [required, String] username for your Tropo user
  # @param [required, String] password for your Tropo user
  # @param [optional, Hash] params 
  # @option params [optional, String] :base_uri to use for accessing the provisioning API if you would like a custom one
  # @return [Object] a TropoProvisioning object
  def initialize(username, password, params={})   
    @username            = username
    @password            = password
    @base_uri            = params[:base_uri] || "http://api.tropo.com/v1"
    @headers             = { 'Content-Type' => 'application/json' }
  end
    
  def account(username, password)
    case current_method_name
    when 'account'
      action = 'get'
    when 'authenticate_account'
      action = 'authenticate'
    end
    temp_request(:get, "/#{action}.jsp?username=#{username}&password=#{password}")
  end
  alias :authenticate_account :account
  
  ##
  # Obtain information about a user
  #
  # @param [required, String] the user ID or username to obtain the account details of
  # @return [Hash]
  #   contains the information on the user
  def user(user_identifier)
    request(:get, { :resource => 'users/' + user_identifier })
  end
  
  ##
  # Confirms a user after they have been created. For example, you may want to email your user to make
  # sure they are real before activating the user.
  #
  # @param [required, String] user_id returned when you created the user you now want to confirm
  # @param [required, String] confirmation_key returned when you created the user you now want to confirm
  # @param [required, String] the ip_address of the user client that did the confirmation
  # @return [Hash]
  #   contains a message key confirming the confirmation was successful
  def confirm_user(user_id, confirmation_key, ip_address)
    params = { :key => confirmation_key, :endUserHost => ip_address }
    request(:post, { :resource => 'users/' + user_id + '/confirmations', :body => params })
  end
  
  ##
  # Creates a new user in a pending state. Once you receive the href/user_id/confirmation_key
  # you may then invoke the confirm_user method once you have taken appropriate steps to confirm the
  # user
  #
  # @param [required, Hash] params to create the user
  # @option params [required, String] :username the name of the user to create the user for
  # @option params [required, String] :password the password to use for the user
  # @option params [required, String] :email the email address to use
  # @option params [optional, String] :first_name of the user
  # @option params [optional, String] :last_name of the user
  # @option params [optional, String] :website the URL of the user's website
  # @option params [optional, String] :organization of the user, such as a company name
  # @option params [optional, String] :job_title of the user
  # @option params [optional, String] :address of the user
  # @option params [optional, String] :address2 second live of the address of the user
  # @option params [optional, String] :city of the user
  # @option params [optional, String] :state of the user
  # @option params [optional, String] :postal_code of the user
  # @option params [optional, String] :country of the user
  # @option params [optional, String] :marketing_opt_in
  # @option params [optional, String] :twitter_id
  # @option params [optional, String] :joined_from_host IP address of the host they signed up from
  # @return [Hash] details of the user created
  #   includes the href, user_id and confirmation_key
  # @raise [ArgumentError]
  #   if missing the :username, :password or :email parameters
  def create_user(params={})
    # Ensure required fields are present
    raise ArgumentError, ':username required' unless params[:username]
    raise ArgumentError, ':password required' unless params[:password]
    raise ArgumentError, ':email required'    unless params[:email]

    # Set the Company Branding ID, or use default
    params[:website] = 'tropo' unless params[:website]    
    
    result = request(:post, { :resource => 'users', :body => params })
    result[:user_id] = get_element(result.href)
    result[:confirmation_key] = result['confirmationKey']
    result.delete('confirmationKey')
    result
  end

  ##
  # Modify/update an existing user
  #
  # @param [required, String] user_id of the user you would like to update
  # @param [required, Hash] the parameters of the user you would like to update
  # @return [Hash]
  #   the href of the resource that was modified/updated
  def modify_user(user_id, params={})
    request(:put, { :resource => 'users/' + user_id, :body => params })
  end
  
  ##
  # Allows you to search users to find a list of users
  #
  # @param [required, String] a key/value of the search term you would like to use, such as 'username=foobar', or 'city=Orlando'
  # @return [Array]
  #   a hash containing an array of hashes with the qualifying account details
  def search_users(search_term)
    request(:get, { :resource => 'users/?' + search_term })
  end
  
  ##
  # Fetches the payment information for a user
  #
  # @param [required, String] user_id to fetch the payment details for
  # @return [Hash]
  #   a hash containing the accountNumber, paymentType, paymentTypeName, rechargeAmount and rechargeThreshold
  def user_payment_method(user_id)
    request(:get, { :resource => 'users/' + user_id + '/payment/method'})
  end
  
  ##
  # Lists the available payment types
  #
  # @return [Hash]
  #   an array of available payment types that each include an id, href and name
  def available_payment_types
    request(:get, { :resource => 'types/payment' })
  end
  
  ##
  # Obtain the current balance of a user
  #
  # @param [required, String] user_id of the user to obtain the balance for
  # @return [Hash]
  #   the balance, pendingRechargeAmount and pendingUsageAmount for the user account
  def balance(user_id)
    request(:get, { :resource => 'users/' + user_id + '/usage'})
  end
  
  ##
  # Lists the available features
  #
  # @return [Hash]
  #   an array of available features that each include an id, href, name and description
  def features
    request(:get, { :resource => 'features' })
  end

  ##
  # Lists the features configured for a user
  #
  # @return [Hash]
  #   an array of available features that each include an href, feature and featureName
  def user_features(user_id)
    request(:get, { :resource => 'users/' + user_id + '/features' })
  end
  
  ##
  # Enable a particular feature for a user
  #
  # @param [required, String] user_id of the user to add the feature to
  # @param [required, String] feature identifier of the feature you want to add
  # @return [Hash]
  #   the href of the feature added
  def user_enable_feature(user_id, feature)
    request(:post, { :resource => 'users/' + user_id + '/features', :body => { :feature => feature } })
  end
  
  ##
  # Disable a particular feature for a user
  #
  # @param [required, String] user_id of the user to disable the feature to
  # @param [required, String] feature number of the feature you want to disable
  # @return [Hash]
  #   the href of the feature disable
  def user_disable_feature(user_id, feature_number)
    request(:delete, { :resource => 'users/' + user_id + '/features/' + feature_number  })
  end
  
  ##
  # Add/modify payment info for a user
  #
  # @param [require, Hash] params the params to add the payment info
  # @option params [required, String] :account_number
  # @option params [required, String] :payment_type
  # @option params [required, String] :address
  # @option params [optional, String] :address2
  # @option params [required, String] :city
  # @option params [required, String] :state
  # @option params [required, String] :postal_code
  # @option params [required, String] :country
  # @option params [optional, String] :email
  # @option params [required, String] :name_on_account
  # @option params [required, String] :expiration_date
  # @option params [required, String] :security_code
  # @option params [optional, String] :phone_number
  # @option params [required, Float] :recharge_amount
  # @option params [required, Float] :recharge_threshold
  # @return [Hash]
  #   the href of the payment method added
  # @raise [ArgumentError]
  #   if a required param is not present
  def add_payment_info(params={})
    raise ArgumentError, ':user_id requried' unless params[:user_id]
    raise ArgumentError, ':account_number required' unless params[:account_number]
    raise ArgumentError, ':payment_type required' unless params[:payment_type]
    raise ArgumentError, ':address required' unless params[:address]
    raise ArgumentError, ':city required' unless params[:city]
    raise ArgumentError, ':state required' unless params[:state]
    raise ArgumentError, ':postal_code required' unless params[:postal_code]
    raise ArgumentError, ':country required' unless params[:country]
    raise ArgumentError, ':name_on_account required' unless params[:name_on_account]
    raise ArgumentError, ':expiration_date required' unless params[:expiration_date]
    raise ArgumentError, ':security_code required' unless params[:security_code]
    raise ArgumentError, ':recharge_amount required' unless params[:recharge_amount]
    
    result = request(:post, { :resource => 'users/' + params[:user_id] + '/payment/method', :body => params })
    result
  end
  alias :modify_payment_info :add_payment_info
  
  ##
  # Makes a payment on behalf of a user
  #
  # @param [required, String] the user_id to make the payment for
  # @param [required, Float] the amount, in US Dollars to make the payment for
  # @return [Hash]
  #   a message with the success or failure of the payment
  def make_payment(user_id, amount)
    request(:post, { :resource => 'users/' + user_id + '/payments', :body => { :amount => amount } })
  end
  
  ##
  # Creates an address to an existing application
  #
  # @param [required, String] application_id to add the address to
  # @param [required, Hash] params the parameters used to request the address
  # @option params [String] :type this defines the type of address. The possibles types are number (phone numbers), pin (reserved), token, aim, jabber, msn, yahoo, gtalk & skype
  # @option params [String] :prefix this defines the country code and area code for phone numbers
  # @option params [String] :username the messaging/IM account's username
  # @option params [String] :password the messaging/IM account's password
  # @return [Hash] params the key/values that make up the application
  # @option params [String] :href identifies the address that was added, refer to address method for details
  # @option params [String] :address the address that was created
  def create_address(application_id, params={})
    raise ArgumentError, ':type required' unless params[:type]
    
    case params[:type].downcase
    when 'number'
      raise ArgumentError, ':prefix required to add a number address' unless params[:prefix] || params[:number]
    when 'aim', 'msn', 'yahoo', 'gtalk'
      raise ArgumentError, ':username and required' unless params[:username]
      raise ArgumentError, ':password and required' unless params[:password]
    when 'jabber'
      raise ArgumentError, ':username required' unless params[:username]
    when 'token'
      raise ArgumentError, ':channel required' unless params[:channel]
      raise ArgumentError, ':channel must be voice or messaging' unless params[:channel] == 'voice' || params[:channel] == 'messaging'
    end
    
    result = request(:post, { :resource => 'applications/' + application_id.to_s + '/addresses', :body => params })
    result[:address] = get_element(result.href)
    result
  end
  
  ##
  # Get a specific application
  #
  # @param [required, String] application_id of the application to get
  # @return [Hash] params the key/values that make up the application
  # @option params [String] :href the REST address for the application
  # @option params [String] :name the name of the application
  # @option params [String] :voiceUrl the URL that powers voice calls for your application
  # @option params [String] :messagingUrl the URL that powers the SMS/messaging calls for your session
  # @option params [String] :platform defines whether the application will use the Scripting API or the Web API
  # @option params [String] :partition defines whether the application is in staging/development or production
  def application(application_id)
    app = request(:get, { :resource => 'applications/' + application_id.to_s })
    app.merge!({ :application_id => get_element(app.href) })
  end
    
  ##
  # Fetches all of the applications configured for a user
  #
  # @return [Hash] contains the results of the inquiry with a list of applications for the authenticated user, refer to the application method for details
  def applications
    results = request(:get, { :resource => 'applications' })
    result_with_ids = []
    results.each do |app|
      result_with_ids << app.merge!({ :application_id => get_element(app.href) })
    end
    result_with_ids
  end
  
  ##
  # Fetches the application(s) with the associated addresses in the hash
  #
  # @param [optional, String] application_id will return a single application with addresses if present
  # @return [Hash] contains the results of the inquiry with a list of applications for the authenticated user, refer to the application method for details
  def applications_with_addresses(application_id=nil)
    if application_id
      associate_addresses_to_application(application(application_id))
    else
      apps = []
      applications.each do |app|
        apps << associate_addresses_to_application(app)
      end
      apps
    end
  end
  alias :application_with_address :applications_with_addresses
  
  ##
  # Create a new application
  #
  # @param [required, Hash] params to create the application
  # @option params [required, String] :name the name to assign to the application
  # @option params [required, String] :partition this defines whether the application is in staging/development or production
  # @option params [required, String] :platform (scripting) whether to use scripting or the webapi
  # @option params [required, String] :messagingUrl or :messaging_url The URL that powers the SMS/messages sessions for your application
  # @option params [required, String] :voiceUrl or :voice_url the URL that powers voices calls for your application
  # @return [Hash] returns the href of the application created and the application_id of the application created
  def create_application(params={})
    merged_params = DEFAULT_OPTIONS.merge(camelize_params(params))
    validate_params merged_params
    result = request(:post, { :resource => 'applications', :body => params })
    result[:application_id] = get_element(result.href)
    result
  end
  
  ##
  # Deletes an application
  #
  # @param [required, String] application_id to be deleted
  # @return [Hash] not sure since it does 204 now, need to check with Cervantes, et al
  def delete_application(application_id)
    request(:delete, { :resource => 'applications/' + application_id.to_s })
  end
  
  ##
  # Deletes a address from a specific application
  #
  # @param [String] application_id that the address is associated to
  # @param [String] address_id for the address
  # @return
  def delete_address(application_id, address_id)
    address_to_delete = address(application_id, address_id)
    
    request(:delete, { :resource => 'applications/' + application_id.to_s + '/addresses/' + address_to_delete['type'] + '/' + address_id.to_s })
  end
  
  ##
  # Provides a list of available exchanges to obtain Numbers from
  #
  # @return [Array] the list of available exchanges
  def exchanges
    request(:get, { :resource => 'exchanges' })
  end
  
  ##
  # Used to move a address between one application and another
  #
  # @param [Hash] params contains a hash of the applications and address to move
  # @option params [required, String] :from
  # @option params [required, String] :to
  # @option params [required, String] :address
  def move_address(params={})
    raise ArgumentError, ':from is required' unless params[:from]
    raise ArgumentError, ':to is required' unless params[:to]
    raise ArgumentError, ':address is required' unless params[:address]
    
    begin
      address_to_move = address(params[:from], params[:address])
      delete_address(params[:from], params[:address])
      request(:post, { :resource => 'applications/' + params[:to] + '/addresses/' + address_to_move['type'] + '/' + params[:address]})
    rescue
      raise RuntimeError, 'Unable to move the address'
    end
  end
  
  ##
  # Get a specific address for an application
  #
  # @param [required, String] application_id to obtain the address for
  # @param [required, String] address_id of the address to obtain the details for
  # @return [Hash] the details of the address
  # @option params [String] :href the REST address for the application
  # @option params [String] :name the name of the application
  # @option params [String] :voiceUrl the URL that powers voices calls for your application
  # @option params [String] :messagingUrl The URL that powers the SMS/messages sessions for your application
  # @option params [String] :partition this defines whether the application is in staging/development or production
  # @option params [String] :type this defines the type of address. The possibles types are number (phone numbers), pin (reserved), token, aim, jabber, msn, yahoo, gtalk & skype
  # @option params [String] :prefix this defines the country code and area code for phone numbers
  # @option params [String] :number the phone number assigned to the application
  # @option params [String] :city the city associated with the assigned phone number
  # @option params [String] :state the state associated with the assigned phone number
  # @option params [String] :channel idenifites the type of channel, maybe 'voice' or 'messaging'
  # @option params [String] :username the messaging/IM account's username
  # @option params [String] :password the messaging/IM account's password
  # @option params [String] :token alphanumeric string that identifies your Tropo application, used with the Session API
  def address(application_id, address_id)
    addresses(application_id).each { |address| return address if address['number']   == address_id || 
                                                                 address['username'] == address_id || 
                                                                 address['pin']      == address_id ||
                                                                 address['token']    == address_id }
    raise RuntimeError, 'Address not found with that application.'
  end
  
  ##
  # Get all of the configured addresses for an application
  #
  # @param [required, String] application_id to fetch the addresses for
  # @return [Hash] all of the addresses configured for the application
  def addresses(application_id)
    request(:get, { :resource => 'applications/' + application_id.to_s + '/addresses' })
  end
  
  ##
  # Updated an existing application
  #
  # @param [required, String] the application id to update
  # @param [required, Hash] params the parameters used to create the application
  # @option params [optional, String] :name the name of the application
  # @option params [optional, String] :voiceUrl the URL that powers voices calls for your application
  # @option params [optional, String] :messagingUrl The URL that powers the SMS/messages sessions for your application
  # @option params [optional, String] :partition whether to create in staging or production
  # @option params [optional, String] :platform whehter to use scripting or the webapi
  # @return [Hash] returns the href of the application created
  def update_application(application_id, params={})
    request(:put, { :resource => 'applications/' + application_id.to_s, :body => params })
  end
  
  ##
  # Get the available partitions available
  #
  # @return [Array]
  #   an array of hashes containing the partitions available
  def partitions
    request(:get, { :resource => 'partitions' })
  end
  
  ##
  # Get the available platforms available under a certain partition
  #
  # @return [Array]
  #   an array of hashes containing the platforms available
  def platforms(partition)
    request(:get, { :resource => 'partitions/' + partition + '/platforms' })
  end
  
  ##
  # Get the whitelist of the numbers on a particular users list
  #
  # @param [required, String] user_id of the user you would like to update
  # @return [Hash]
  #   the href and value containing the number on the whitelist
  def whitelist(user_id)
    request(:get, { :resource => 'users/' + user_id + '/partitions/production/platforms/sms/whitelist' })
  end
  
  ##
  # Add to a whitelist for a particular user
  #
  # @param [required, String] user_id of the user you would like to update
  # @param [required, String] value the number or address you would like to add to the whitelist
  # @return [Hash]
  #   the href 
  def add_whitelist(user_id, value)
    request(:post, { :resource => 'users/' + user_id + '/partitions/production/platforms/sms/whitelist', :body => { :value => value } })
  end

  ##
  # Delete from a whitelist for a particular user
  #
  # @param [required, String] user_id of the user 
  # @param [required, String] value the number or address you would like to delete from the whitelist
  # @return [Hash]
  #   the href 
  def delete_whitelist(user_id, value)
    request(:delete, { :resource => 'users/' + user_id + '/partitions/production/platforms/sms/whitelist/' + value })
  end
  
  private
  
  ##
  #
  def camelize_params(params)
    camelized = {}
    params.each { |k,v| camelized.merge!(k.to_s.camelize(:lower).to_sym => v) }
    camelized
  end
  
  ##
  # Returns the current method name
  #
  # @return [String] current method name
  def current_method_name
    caller[0] =~ /`([^']*)'/ and $1
  end
  
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
  
  ##
  # Parses the URL and returns the last element
  #
  # @param [required, String] the URL to parse for the application ID
  # @return [String] the application id parsed from the URL
  def get_element(url)
    url.split('/').last
  end
  
  ##
  # Associates the addresses to an application
  #
  # @param [Object] application object to associate the address to
  # @return [Object] returns the application object with the associated addresses embedded
  def associate_addresses_to_application(app)
    add = addresses(app.application_id)
    app.merge!({ :addresses => add })
  end
  
  ##
  # Creates the appropriate URI and HTTP handlers for our request
  #
  # @param [required, Symbol] the HTTP action to use :delete, :get, :post or :put
  # @param [required, Hash] params used to create the request
  # @option params [String] :resource the resource to call on the base URL
  # @option params [Hash] :body the details to use when posting, putting or deleting an object, converts into the appropriate JSON
  # @return [Hash] the result of the request
  # @raise [RuntimeError]
  #   if it can not connect to the API server or if the response.code is not 200 
  def request(method, params={})
    params[:body] = camelize_params(params[:body]) if params[:body]
    
    if params[:resource]
      uri = URI.parse(@base_uri + '/' + params[:resource])
    else
      uri = URI.parse(@base_uri)
    end
    http = Net::HTTP.new(uri.host, uri.port)

    request = set_request_type(method, uri)
    request.initialize_http_header(@headers)
    request.basic_auth @username, @password
    request.body = ActiveSupport::JSON.encode params[:body] if params[:body]
    
    begin
      response = http.request(request)
    rescue => e
      raise RuntimeError, "Unable to connect to the Provisioning API server - #{e.to_s}"
    end

    raise RuntimeError, "#{response.code}: #{response.message} - #{response.body}" unless response.code == '200'

    result = ActiveSupport::JSON.decode response.body
    if result.instance_of? Array
      hashie_array(result)
    else
      Hashie::Mash.new(result)
    end
  end
  
  ##
  # Creates the appropriate request for the temporary Evolution account API
  #
  # @return [Hash] the result of the request
  def temp_request(method, fields)
    #base_uri = 'http://evolution.voxeo.com/api/account'
    base_uri = 'http://web141.supernonstop.com/api/account'
    uri = URI.parse(base_uri + fields)
    http = Net::HTTP.new(uri.host, uri.port)

    request = set_request_type(method, uri)
    request.initialize_http_header(@headers)

    response = http.request(request)
    raise RuntimeError, "#{response.code} - #{response.message}" unless response.code == '200'

    result = ActiveSupport::JSON.decode response.body
    if result.instance_of? Array
      hashie_array(result)
    else
      Hashie::Mash.new(result)
    end
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
      Net::HTTP::Delete.new(uri.request_uri)
    when :get
      Net::HTTP::Get.new(uri.request_uri)
    when :post
      Net::HTTP::Post.new(uri.request_uri)
    when :put
      Net::HTTP::Put.new(uri.request_uri)
    end
  end
  
  ##
  # Validates that we have all of the appropriate params when creating an application
  #
  # @param [Hash] params to create the application
  # @option params [required, String] :name the name to assign to the application
  # @option params [required, String] :partition whether to create in staging or production
  # @option params [required, String] :platform whehter to use scripting or the webapi
  # @option params [String] :messagingUrl the Url to use for handiling messaging requests
  # @option params [String] :voiceUrl the Url to use for handling voice requests
  # @return nil
  def validate_params(params={})
    # Make sure all of the arguments are present
    raise ArgumentError, ':name required' unless params[:name]
    raise ArgumentError, ':messagingUrl or :voiceUrl required' unless params[:messagingUrl] || params[:voiceUrl]
    
    # Make sure the arguments have valid values
    raise ArgumentError, ":platform must be 'scripting' or 'webapi'" unless params[:platform] == 'scripting' || params[:platform] == 'webapi'
    raise ArgumentError, ":partiion must be 'staging' or 'production'" unless params[:partition] == 'staging' || params[:partition] == 'production'
  end
end