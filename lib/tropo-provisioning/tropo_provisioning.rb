require 'active_support'
require 'active_support/inflector'

##
# This class is a wrapper that allows an easy way to access Tropo HTTP Provisioning API
# It defines a set of methods to create, update, retrieve or delete different kind of resources.
class TropoProvisioning

  autoload :TropoClient, 'tropo-provisioning/tropo_client'
  autoload :TropoError, 'tropo-provisioning/tropo_error'

  # Defaults for the creation of applications
  DEFAULT_OPTIONS = { :partition => 'staging', :platform  => 'scripting' }

  # Array of supported platforms in Tropo
  VALID_PLATFORMS = %w(scripting webapi)
  # Array of supported partitions in Tropo
  VALID_PARTITIONS = %w(staging production)

  attr_reader :user_data, :base_uri

  ##
  # Creates a new TropoProvisioning object
  #
  # ==== Parameters
  # * [required, String] username for your Tropo user
  # * [required, String] password for your Tropo user
  # * [optional, Hash] params
  #   * [optional, String] :base_uri to use for accessing the provisioning API if you would like a custom one
  #
  # ==== Return
  #
  # TropoProvisioning object
  def initialize(username, password, params={})
    @base_uri           =  (params[:base_uri] || "https://api.tropo.com/v1/").sub(/(\/)+$/,'/')
    proxy               =  params[:proxy]    || nil
    @tropo_client       =  TropoClient.new(username, password, @base_uri, { 'Content-Type' => 'application/json' }, proxy)
    user(username)
  end

  ##
  # Retrieves specific user information
  # ==== Parameters
  def account(username, password)
    case current_method_name
    when 'account'
      action = 'get'
    when 'authenticate_account'
      action = 'authenticate'
    end
    temp_request("/#{action}.jsp?username=#{username}&password=#{password}")
  end

  ##
  # Username used for HTTP authentication (valid Tropo user)
  def username
    @tropo_client.username
  end

  alias :authenticate_account :account

  ##
  # Obtain information about a user
  #
  # ==== Parameters
  # * [required, String] the user ID or username to obtain the account details of
  #
  # ==== Return
  # * [Hash]
  #   contains the information on the user
  def user(user_identifier)
    result = @tropo_client.get("users/#{user_identifier}")
    if result['username']
      # Only add/update this if we are fetching the user we are logged in as
      result['username'].downcase == username.downcase and @user_data = result
    end
    result
  end

  ##
  # Confirms a user after they have been created. For example, you may want to email your user to make
  # sure they are real before activating the user.
  #
  # ==== Parameters
  # * [required, String] user_id returned when you created the user you now want to confirm
  # * [required, String] confirmation_key returned when you created the user you now want to confirm
  # * [required, String] the ip_address of the user client that did the confirmation
  #
  # ==== Return
  # * [Hash]
  #   contains a message key confirming the confirmation was successful
  def confirm_user(user_id, confirmation_key, ip_address)
    params = { :key => confirmation_key, :endUserHost => ip_address }
    @tropo_client.post("users/#{user_id}/confirmations", params)
  end

  ##
  # Creates a new user in a pending state. Once you receive the href/user_id/confirmation_key
  # you may then invoke the confirm_user method once you have taken appropriate steps to confirm the
  # user
  #
  # ==== Parameters
  # * [required, Hash] params to create the user
  #   * [required, String] :username the name of the user to create the user for
  #   * [required, String] :password the password to use for the user
  #   * [required, String] :email the email address to use
  #   * [required, String] :first_name of the user
  #   * [required, String] :last_name of the user
  #   * [optional, String] :website the URL of the user's website
  #   * [optional, String] :organization of the user, such as a company name
  #   * [optional, String] :job_title of the user
  #   * [optional, String] :address of the user
  #   * [optional, String] :address2 second live of the address of the user
  #   * [optional, String] :city of the user
  #   * [optional, String] :state of the user
  #   * [optional, String] :postal_code of the user
  #   * [optional, String] :country of the user
  #   * [optional, String] :marketing_opt_in
  #   * [optional, String] :twitter_id
  #   * [optional, String] :joined_from_host IP address of the host they signed up from
  #
  # ==== Return
  # * [Hash] details of the user created
  #   includes the href, user_id and confirmation_key
  # * [ArgumentError]
  #   if missing the :username, :password or :email parameters
  def create_user(params={})
    validate_params(params, %w(username password first_name last_name email))

    # Set the Company Branding ID, or use default
    params[:website] = 'tropo' unless params[:website]

    result = @tropo_client.post("users", params)
    result[:user_id] = get_element(result.href)
    result[:confirmation_key] = result['confirmationKey']
    result.delete('confirmationKey')
    result
  end

  ##
  # Modify/update an existing user
  #
  # ==== Parameters
  # * [required, String] user_id of the user you would like to update
  # * [required, Hash] the parameters of the user you would like to update
  #
  # ==== Return
  # * [Hash]
  #   the href of the resource that was modified/updated
  def modify_user(user_id, params={})
    result = @tropo_client.put("users/#{user_id}", params)
    if result['href']
      # Only add/update this if we are fetching the user we are logged in as
      @user_data.merge!(params) if user_id == @user_data['id']
    end
    result
  end

  ##
  # Allows you to search users to find a list of users
  #
  # ==== Parameters
  # * [required] search_term
  #   * [String] a key/value of the search term you would like to use, such as 'username=foobar', or 'city=Orlando'
  #   * [Hash] a Hash instance, such as {"username" => "foobar"}, or {"city" => "Orlando"}
  #
  # ==== Return
  # * [Array]
  #   a hash containing an array of hashes with the qualifying account details
  def search_users(search_term)
    if search_term.is_a?(String)
      @tropo_client.get("users/?#{search_term}")
    elsif search_term.is_a?(Hash)
      @tropo_client.get('users/', search_term)
    else
      nil
    end
  end

  ##
  # Allows you to search if a username exists or not
  #
  # ==== Parameters
  # * [required, String] a username to check
  # ==== Return
  # * [Array]
  #   a hash containing an array of hashes with the qualifying account details
  def username_exists?(username)
    @tropo_client.get("usernames/#{username}")
  end

  ##
  # Fetches the payment information for a user
  #
  # ==== Parameters
  # * [required, String] user_id to fetch the payment details for
  #
  # ==== Return
  # * [Hash]
  #   a hash containing the accountNumber, paymentType, paymentTypeName, rechargeAmount and rechargeThreshold
  def user_payment_method(user_id)
    result = @tropo_client.get("users/#{user_id}/payment/method")
    result.merge!({ :id => get_element(result.paymentType) })
    result
  end

  ##
  # Lists the available payment types
  #
  # ==== Return
  # * [Hash]
  #   an array of available payment types that each include an id, href and name
  def available_payment_types
    @tropo_client.get("types/payment")
  end

  ##
  # Obtain the current balance of a user
  #
  # ==== Parameters
  # * [required, String] user_id of the user to obtain the balance for
  #
  # ==== Return
  # * [Hash]
  #   the balance, pendingRechargeAmount and pendingUsageAmount for the user account
  def balance(user_id)
    @tropo_client.get("users/#{user_id}/usage")
  end

  ##
  # Return the list of available countries
  #
  # ==== Return
  # * [Hash]
  #   returns an Array of hashes that include the country details available
  def countries
    result = @tropo_client.get("countries")
    add_ids(result)
  end

  ##
  # Return the list of available states for a country
  #
  # ==== Return
  # * [Hash]
  #   returns an Array of hashes that include the state details for a country that are available
  def states(id)
    result = @tropo_client.get("countries/#{id}/states")
    add_ids(result)
  end

  ##
  # Lists the available features
  #
  # ==== Return
  # * [Hash]
  #   an array of available features that each include an id, href, name and description
  def features
    @tropo_client.get("features")
  end

  ##
  # Lists the features configured for a user
  #
  # ==== Return
  # * [Hash]
  #   an array of available features that each include an href, feature and featureName
  def user_features(user_id)
    @tropo_client.get("users/#{user_id}/features")
  end

  ##
  # Enable a particular feature for a user
  #
  # ==== Parameters
  # * [required, String] user_id of the user to add the feature to
  # * [required, String] feature identifier of the feature you want to add
  #
  # ==== Return
  # * [Hash]
  #   the href of the feature added
  def user_enable_feature(user_id, feature)
    @tropo_client.post("users/#{user_id}/features", { :feature => feature })
  end

  ##
  # Disable a particular feature for a user
  #
  # ==== Parameters
  # * [required, String] user_id of the user to disable the feature to
  # * [required, String] feature number of the feature you want to disable
  #
  # ==== Return
  # * [Hash]
  #   the href of the feature disable
  def user_disable_feature(user_id, feature_number)
    @tropo_client.delete("users/#{user_id}/features/#{feature_number}")
  end

  ##
  # Add/modify payment info for a user
  #
  # ==== Parameters
  # * [user_id - required, String]  to add the payment details for
  # * [require, Hash] params the params to add the payment info
  #   * [:account_number] [required, String] the credit card number
  #   * [required, String] :payment_type the type, such as visa, mastercard, etc
  #   * [required, String] :address
  #   * [optional, String] :address2
  #   * [required, String] :city
  #   * [required, String] :state
  #   * [required, String] :postal_code
  #   * [required, String] :country
  #   * [optional, String] :email
  #   * [required, String] :name_on_account name on the credit card
  #   * [required, String] :expiration_date expiration date of the credit card
  #   * [required, String] :security_code back panel/front panel (Amex) code on the card
  #   * [optional, String] :phone_number
  #
  # ==== Return
  # * [Hash]
  #   the href of the payment method added
  # * [ArgumentError]
  #   if a required param is not present
  def add_payment_info(user_id, params={})
    #validate_params(params, %w(account_number payment_type address city state postal_code country name_on_account expiration_date security_code recharge_amount email phone_number))
    @tropo_client.put("users/#{user_id}/payment/method", params)
  end
  alias :modify_payment_info :add_payment_info

  ##
  # Add/modify recurring fund amount and threshold
  #
  # ==== Parameters
  # * [required, String] user_id to add the payment details for
  # * [require, Hash] params the params to add the recurrence
  #   * [required, Float] :recharge_amount
  #   * [required, Float] :recharge_threshold
  #
  # ==== Return
  # * [Hash]
  def update_recurrence(user_id, params={})
    validate_params(params, %w(recharge_amount threshold_percentage))

    @tropo_client.put("users/#{user_id}/payment/recurrence", params)
  end

  ##
  # Add/modify recurring fund amount and threshold
  #
  # ==== Parameters
  # * [required, String] user_id to get the recurrence info for
  #
  # ==== Return
  # * [Hash]
  def get_recurrence(user_id)
    result = @tropo_client.get("users/#{user_id}/payment/recurrence")
  end

  ##
  # Makes a payment on behalf of a user
  #
  # ==== Parameters
  # * [required, String] the user_id to make the payment for
  # * [required, Float] the amount, in US Dollars to make the payment for
  #
  # ==== Return
  # * [Hash]
  #   a message with the success or failure of the payment
  def make_payment(user_id, amount)
    amount.instance_of?(Float) or raise ArgumentError, 'amount must be of type Float'

    @tropo_client.post("users/#{user_id}/payments", { :amount => amount })
  end

  ##
  # Creates an address to an existing application
  #
  # ==== Parameters
  # * [required, String] application_id to add the address to
  # * [required, Hash] params the parameters used to request the address
  #   * [String] :type this defines the type of address. The possibles types are number (phone numbers), pin (reserved), token, aim, jabber, msn, yahoo, gtalk & skype
  #   * [String] :prefix this defines the country code and area code for phone numbers
  #   * [String] :username the messaging/IM account's username
  #   * [String] :password the messaging/IM account's password
  #
  # ==== *Return*
  # * [Hash] params the key/values that make up the application
  #   * [String] :href identifies the address that was added, refer to address method for details
  #   * [String] :address the address that was created
  def create_address(application_id, params={})
    validate_address_parameters(params)

    result = @tropo_client.post("applications/#{application_id.to_s}/addresses", params)
    result[:address] = get_element(result.href)
    result
  end

  ##
  # Get a specific application
  #
  # ==== Parameters
  # * [required, String] application_id of the application to get
  #
  # ==== Return
  # * [Hash] params the key/values that make up the application
  #   * [String] :href the REST address for the application
  #   * [String] :name the name of the application
  #   * [String] :voiceUrl the URL that powers voice calls for your application
  #   * [String] :messagingUrl the URL that powers the SMS/messaging calls for your session
  #   * [String] :platform defines whether the application will use the Scripting API or the Web API
  #   * [String] :partition defines whether the application is in staging/development or production
  def application(application_id)
    app = @tropo_client.get("applications/#{application_id.to_s}")
    if app.instance_of? Array
      href = app[0].href
      app[0].merge!({ :application_id => get_element(href) })
    else
      href = app.href
      app.merge!({ :application_id => get_element(href) })
    end
  end

  ##
  # Fetches all of the applications configured for a user
  #
  # ==== Return
  # * [Hash] contains the results of the inquiry with a list of applications for the authenticated user, refer to the application method for details
  def applications
    results = @tropo_client.get("applications")
    result_with_ids = []
    results.each do |app|
      result_with_ids << app.merge!({ :application_id => get_element(app.href) })
    end
    result_with_ids
  end

  ##
  # Fetches the application(s) with the associated addresses in the hash
  #
  # ==== Parameters
  # * [optional, String] application_id will return a single application with addresses if present
  #
  # ==== Return
  # * [Hash] contains the results of the inquiry with a list of applications for the authenticated user, refer to the application method for details
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
  # ==== Parameters
  # * [required, Hash] params to create the application
  #   * [required, String] :name the name to assign to the application
  #   * [required, String] :partition this defines whether the application is in staging/development or production
  #   * [required, String] :platform (scripting) whether to use scripting or the webapi
  #   * [required, String] :messagingUrl or :messaging_url The URL that powers the SMS/messages sessions for your application
  #   * [optional, String] :voiceUrl or :voice_url the URL that powers voices calls for your application
  #
  # ==== Return
  # * [Hash] returns the href of the application created and the application_id of the application created
  def create_application(params={})
    merged_params = DEFAULT_OPTIONS.merge(params)
    validate_application_params(merged_params)
    result = @tropo_client.post("applications", params)
    result[:application_id] = get_element(result.href)
    result
  end

  ##
  # Deletes an application
  #
  # ==== Parameters
  # * [required, String] application_id to be deleted
  #
  # ==== Return
  # * [Hash] not sure since it does 204 now, need to check with Cervantes, et al
  def delete_application(application_id)
    @tropo_client.delete("applications/#{application_id.to_s}")
  end

  ##
  # Deletes a address from a specific application
  #
  # ==== Parameters
  # * [String] application_id that the address is associated to
  # * [String] address_id for the address
  def delete_address(application_id, address_id)
    address_to_delete = address(application_id, address_id)

    @tropo_client.delete("applications/#{application_id.to_s}/addresses/#{address_to_delete['type']}/#{address_id.to_s}")
  end

  ##
  # Provides a list of available exchanges to obtain Numbers from
  #
  # ==== Return
  # * [Array] the list of available exchanges
  def exchanges
    @tropo_client.get("exchanges")
  end

  ##
  # Used to move a address between one application and another
  #
  # ==== Parameters
  # * [Hash] params contains a hash of the applications and address to move
  #   * [required, String] :from
  #   * [required, String] :to
  #   * [required, String] :address
  def move_address(params={})
    validate_params(params, %w(from to address))

    begin
      address_to_move = address(params[:from], params[:address])
      delete_address(params[:from], params[:address])
      @tropo_client.post("applications/#{params[:to]}/addresses/#{address_to_move['type']}/#{params[:address]}")
    rescue
      raise RuntimeError, 'Unable to move the address'
    end
  end

  ##
  # Get a specific address for an application
  #
  # ==== Parameters
  # * [required, String] application_id to obtain the address for
  # * [required, String] address_id of the address to obtain the details for
  #
  # ==== Return
  # * [Hash] the details of the address
  #   * [String] :href the REST address for the application
  #   * [String] :name the name of the application
  #   * [String] :voiceUrl the URL that powers voices calls for your application
  #   * [String] :messagingUrl The URL that powers the SMS/messages sessions for your application
  #   * [String] :partition this defines whether the application is in staging/development or production
  #   * [String] :type this defines the type of address. The possibles types are number (phone numbers), pin (reserved), token, aim, jabber, msn, yahoo, gtalk & skype
  #   * [String] :prefix this defines the country code and area code for phone numbers
  #   * [String] :number the phone number assigned to the application
  #   * [String] :city the city associated with the assigned phone number
  #   * [String] :state the state associated with the assigned phone number
  #   * [String] :channel idenifites the type of channel, maybe 'voice' or 'messaging'
  #   * [String] :username the messaging/IM account's username
  #   * [String] :password the messaging/IM account's password
  #   * [String] :token alphanumeric string that identifies your Tropo application, used with the Session API
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
  # ==== Parameters
  # * [required, String] application_id to fetch the addresses for
  #
  # ==== Return
  # * [Hash] all of the addresses configured for the application
  def addresses(application_id)
    @tropo_client.get("applications/#{application_id.to_s}/addresses")
  end

  ##
  # Updated an existing application
  #
  # ==== Parameters
  # * [required, String] the application id to update
  # * [required, Hash] params the parameters used to create the application
  #   * [optional, String] :name the name of the application
  #   * [optional, String] :voiceUrl the URL that powers voices calls for your application
  #   * [optional, String] :messagingUrl The URL that powers the SMS/messages sessions for your application
  #   * [optional, String] :partition whether to create in staging or production
  #   * [optional, String] :platform whehter to use scripting or the webapi
  #
  # ==== Return
  # * [Hash] returns the href of the application created
  def update_application(application_id, params={})
    @tropo_client.put("applications/#{application_id.to_s}", params )
  end

  ##
  # Fetch all invitations, or invitations by user
  #
  # @overload def invitations()
  # @overload def user_inivitations(user_id)
  # ==== Parameters
  #   * [optional, String] the user_id to fetch the invitations for, if not present, will fetch all invitations
  #
  # ==== Return
  # * [Hash] returns a list of the invitations
  def invitations(user_id = nil)
    if user_id
      @tropo_client.get("users/#{user_id}/invitations")
    else
      @tropo_client.get("invitations")
    end
  end
  alias :user_invitations :invitations

  ##
  # Fetch an invitation
  #
  # @overload def invitation(invitation_id)
  # ==== Parameters
  #   * [required, String] the invitation id to fetch
  # @overload def user_invitation(user_id, invitation_id)
  # ==== Parameters
  #   * [required, String] the invitation id to fetch
  #   * [optional, String] the user id to fetch the invitation for
  #
  # ==== Return
  # * [Hash] return an invitation
  def invitation(invitation_id, user_id = nil)
    path = user_id.nil? ? "invitations/#{invitation_id}" : "users/#{user_id}/invitations/#{invitation_id}"

    @tropo_client.get(path)
  end

  alias :user_invitation :invitation

  ##
  # Fetch an invitation
  #
  # @overload def delete_invitation(invitation_id)
  # ==== Parameters
  #   * [required, String] the invitation id to delete
  # @overload def delete_user_invitation(invitation_id, user_id)
  # ==== Parameters
  #  * [required, String] the invitation id to delete
  #  * [required, String] the user id to delete
  #
  # ==== Return
  # * [Hash] return an invitation
  def delete_invitation(invitation_id, user_id = nil)
    path = user_id.nil? ? "invitations/#{invitation_id}" : "users/#{user_id}/invitations/#{invitation_id}"

    @tropo_client.delete(path)
  end

  alias :delete_user_invitation :delete_invitation

  ##
  # Create an invitation
  #
  # @overload def create_invitation(options)
  # ==== Parameters
  #   * [required, Hash] params the parameters used to create the application
  #     * [optional, String] :code the invitation code (defaults to a random alphanum string of length 6 if not specified on POST)
  #     * [optional, String] :count the number of accounts that may signup with this code (decrements on each signup)
  #     * [optional, String] :credit starting account balance for users who signup with this code (replaces the default for the brand)
  #     * [optional, String] :partition whether to create in staging or production
  #     * [optional, String] :owner URI identifying the user to which this invite code belongs (optional - null implies this is a "global" code)
  # @overload def create_user_invitation(user_id, options)
  # ==== Parameters
  #   * [requried, String] user_id to create the invitation for
  #   * [required, Hash] params the parameters used to create the application
  #     * [optional, String] :code the invitation code (defaults to a random alphanum string of length 6 if not specified on POST)
  #     * [optional, String] :count the number of accounts that may signup with this code (decrements on each signup)
  #     * [optional, String] :credit starting account balance for users who signup with this code (replaces the default for the brand)
  #     * [optional, String] :partition whether to create in staging or production
  #     * [optional, String] :owner URI identifying the user to which this invite code belongs (optional - null implies this is a "global" code)
  #
  # ==== Return
  # * [Hash] returns the href of the invitation created
  def create_invitation(*args)
    if args.length == 1
      @tropo_client.post("invitations", args[0])
    elsif args.length == 2
      @tropo_client.post("users/#{args[0]}/invitations", args[1])
    end
  end
  alias :create_user_invitation :create_invitation

  ##
  # Update an invitation
  #
  # @overload def update_invitation(invitation_id, options)
  # ==== Parameters
  #   * [required, String] id of the invitation to udpate (code)
  #   * [required, Hash] params the parameters used to update the application
  #     * [optional, String] :count the number of accounts that may signup with this code (decrements on each signup)
  #     * [optional, String] :credit starting account balance for users who signup with this code (replaces the default for the brand)
  #     * [optional, String] :partition whether to create in staging or production
  #     * [optional, String] :owner URI identifying the user to which this invite code belongs (optional - null implies this is a "global" code)
  # @overload def updated_user_invitation(invitation_id, user_id, options)
  # ==== Parameters
  #   * [required, String] id of the invitation to udpate (code)
  #   * [required, String] id of the user to update the invitation code for
  #   * [required, Hash] params the parameters used to update the application
  #     * [optional, String] :count the number of accounts that may signup with this code (decrements on each signup)
  #     * [optional, String] :credit starting account balance for users who signup with this code (replaces the default for the brand)
  #     * [optional, String] :partition whether to create in staging or production
  #     * [optional, String] :owner URI identifying the user to which this invite code belongs (optional - null implies this is a "global" code)
  #
  # ==== Return
  # * [Hash] returns the href of the invitation created
  def update_invitation(*args)
    if args.length == 2
      @tropo_client.put("invitations/#{args[0]}", args[1])
    elsif args.length == 3
      @tropo_client.put("users/#{args[1]}/invitations/#{args[0]}", args[2])
    end
  end
  alias :update_user_invitation :update_invitation

  ##
  # Get the available partitions available
  #
  # ==== Return
  # * [Array]
  #   an array of hashes containing the partitions available
  def partitions
    @tropo_client.get("partitions")
  end

  ##
  # Get the available platforms available under a certain partition
  #
  # ==== Parameters
  #
  # ==== Return
  # * [Array]
  #   an array of hashes containing the platforms available
  def platforms(partition)
    @tropo_client.get("partitions/#{partition}/platforms")
  end

  ##
  # Get the whitelist of the numbers on a particular users list
  #
  # ==== Parameters
  # * [required, String] user_id of the user you would like to update
  #
  # ==== Return
  # * [Hash]
  #   the href and value containing the number on the whitelist
  def whitelist(user_id = nil)
    resource = user_id.nil? ? "users/partitions/production/platforms/sms/whitelist" : "users/#{user_id}/partitions/production/platforms/sms/whitelist"

    @tropo_client.get(resource)
  end

  ##
  # Add to a whitelist for a particular user
  #
  # ==== Parameters
  # * [Hash] params contains a hash of the user_id and value to add
  #   * [optional, String] :user_id if present the user_id to add to, if not it will add to the user logged in as
  #   * [required, String] :value the value to add to the whitelist
  #
  # ==== Return
  # * [Hash]
  #   the href
  def add_whitelist(params={})
    resource = params.has_key?(:user_id) ?
    "users/#{params[:user_id]}/partitions/production/platforms/sms/whitelist" :
    "users/partitions/production/platforms/sms/whitelist"
    @tropo_client.post(resource, {:value => params[:value]})
  end

  ##
  # Delete from a whitelist for a particular user
  #
  # * [Hash] params contains a hash of the user_id and value to delete
  #   * [optional, String] :user_id if present the user_id to delete from, if not it will add to the user logged in as
  #   * [required, String] :value the value to delete from the whitelist
  #
  # ==== Return
  # * [Hash]
  #   the href
  def delete_whitelist(params={})
    resource = params.has_key?(:user_id) ? "users/#{params[:user_id]}/partitions/production/platforms/sms/whitelist/" : "users/partitions/production/platforms/sms/whitelist/"

    @tropo_client.delete("#{resource}#{params[:value]}")
  end

  private

  ##
  # Returns the current method name
  #
  # ==== Return
  # * [String] current method name
  def current_method_name
    caller[0] =~ /`([^']*)'/ and $1
  end

  ##
  # Adds the IDs to an Array of Hashes if no ID is present
  #
  # ==== Parameters
  # * [required, Array] array of hashes to add IDs to
  #
  # ==== Return
  # * [Array]
  #   the array of hashes with ID added
  def add_ids(array)
    array.each do |element|
      element[:id].nil? and element[:id] = get_element(element.href)
    end
    array
  end

  ##
  # Parses the URL and returns the last element
  #
  # ==== Parameters
  # * [required, String] the URL to parse for the application ID
  #
  # ==== Return
  # * [String] the application id parsed from the URL
  def get_element(url)
    url.split('/').last
  end

  ##
  # Associates the addresses to an application
  #
  # ==== Parameters
  # * [Object] application object to associate the address to
  #
  # ==== Return
  # * [Object] returns the application object with the associated addresses embedded
  def associate_addresses_to_application(app)
    add = addresses(app.application_id)
    app.merge!({ :addresses => add })
  end

  ##
  # Creates the appropriate request for the temporary Evolution account API
  #
  # ==== Parameters
  # * [required, String] path: URI path
  # ==== Return
  # * [Hash] the result of the request
  def temp_request(path)
    #base_uri = 'http://evolution.voxeo.com/api/account'
    base_uri = 'http://web141.supernonstop.com/api/account'
    uri = URI.parse(base_uri + path)
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Delete.new(uri)
    request.initialize_http_header({'Content-Type' => 'application/json'})

    response = http.request(request)
    raise TropoError, "#{response.code} - #{response.message}" unless response.code == '200'

    result = ActiveSupport::JSON.decode response.body
    if result.instance_of? Array
      hashie_array(result)
    else
      Hashie::Mash.new(result)
    end
  end


  ##
  # Used to validate required params in either underscore or camelCase formats
  #
  # ==== Parameters
  # * [required, Hash] params to be checked
  # * [required, Array] requirements of which fields much be present
  #
  # ==== Returns
  # * ArgumentError
  #   if a param is not present that is required
  def validate_params(params, requirements)
    requirements.each do |requirement|
      if params[requirement.to_sym].nil? && params[requirement.to_s.camelize(:lower).to_sym].nil? && params[requirement].nil? && params[requirement.to_s.camelize(:lower)].nil?
        raise ArgumentError, ":#{requirement} is a required parameter"
        break
      end
    end
  end

  ##
  # Validates that we have all of the appropriate params when creating an application
  #
  # ==== Parameters
  # * [Hash] params to create the application
  #   * [required, String] :name the name to assign to the application
  #   * [required, String] :partition whether to create in staging or production
  #   * [required, String] :platform whehter to use scripting or the webapi
  #   * [String] :messagingUrl the Url to use for handiling messaging requests
  #   * [String] :voiceUrl the Url to use for handling voice requests
  #
  # ==== Return
  # * nil
  def validate_application_params(params={})
    # Make sure all of the arguments are present
    raise ArgumentError, ':name is a required parameter' unless params[:name] || params['name']

    # Make sure the arguments have valid values
    raise ArgumentError, ":platform must be #{VALID_PLATFORMS.map{|platform| "\'#{platform}\'"}.join(' or ')}" unless VALID_PLATFORMS.include?(params[:platform]) or VALID_PLATFORMS.include?(params["platform"])
    raise ArgumentError, ":partition must be #{VALID_PARTITIONS.map{|partition| "\'#{partition}\'"}.join(' or ')}" unless VALID_PARTITIONS.include?(params[:partition]) or VALID_PARTITIONS.include?(params["partition"])
  end

  ##
  # Validates a create address request parameters
  #
  # ==== Parameters
  # * [required, Hash] required parameters values
  #
  # ==== Return
  # * nil if successful validation
  # * ArgumentError is a required parameter is missing
  #
  def validate_address_parameters(params={})
    raise ArgumentError, ":type is a required parameter" unless params[:type] || params['type']

    case params[:type].downcase
    when 'number'
      raise ArgumentError, ':prefix required to add a number address' unless params[:prefix] || params[:number] || params['prefix'] || params['number']
    when 'aim', 'msn', 'yahoo', 'gtalk'
      raise ArgumentError, ':username is a required parameter' unless params[:username] || params['username']
      raise ArgumentError, ':password is a required parameter' unless params[:password] || params ['password']
    when 'jabber'
      raise ArgumentError, ':username is a required parameter' unless params[:username] || params['username']
    when 'token'
      raise ArgumentError, ':channel is a required parameter' unless params[:channel] || params['channel']
      raise ArgumentError, ':channel must be voice or messaging' unless params[:channel] == 'voice' || params[:channel] == 'messaging' || params['channel'] == 'voice' || params['channel'] == 'messaging'
    end
  end
end
