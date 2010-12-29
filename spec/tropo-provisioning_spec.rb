require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

# These tests are all local unit tests
FakeWeb.allow_net_connect = false

describe "TropoProvisioning" do
  before(:all) do
    @applications = [ { "voiceUrl"    => "http://webhosting.voxeo.net/1234/www/simple.js", 
                        "name"         => "API Test", 
                        "href"         => "http://api.tropo.com/v1/applications/108000", 
                        "partition"    => "staging", 
                        "platform"     => "scripting" }, 
                      { "voiceUrl"    => "http://hosting.tropo.com/1234/www/simon.rb", 
                        "name"         => "Simon Game", 
                        "href"         => "http://api.tropo.com/v1/applications/105838", 
                        "partition"    => "staging", 
                        "messagingUrl" => "http://hosting.tropo.com/1234/www/simon.rb", 
                        "platform"     => "scripting" },
                      { "voiceUrl"    => "http://webhosting.voxeo.net/1234/www/simple.js", 
                        "name"         => "Foobar", 
                        "href"         => "http://api.tropo.com/v1/applications/108002", 
                        "partition"    => "staging", 
                        "platform"     => "scripting" } ]
    
    @addresses = [ { "region" => "I-US", 
                     "city"     => "iNum US", 
                     "number"   => "883510001812716", 
                     "href"     => "http://api.tropo.com/v1/applications/108000/addresses/number/883510001812716", 
                     "prefix"   => "008", 
                     "type"     => "number" }, 
                   { "number"   => "9991436301", 
                     "href"     => "http://api.tropo.com/v1/applications/108000/addresses/pin/9991436300", 
                     "type"     => "pin" },
                   { "href"     => "http://api.tropo.com/v1/applications/108000/addresses/jabber/xyz123", 
                     "nickname" => "", 
                     "username" => "xyz123", 
                     "type"     => "jabber" },
                   { "href"     => "http://api.tropo.com/v1/applications/108000/addresses/jabber/xyz123", 
                     "nickname" => "", 
                     "username" => "9991436300", 
                     "type"     => "pin" },
                   { "href"     => "http://api.tropo.com/v1/applications/108000/addresses/token/a1b2c3d4", 
                     "nickname" => "", 
                     "username" => "a1b2c3d4", 
                     "type"     => "token" } ]
    
    @exchanges =  '[
                     {
                        "prefix":"1407",
                        "city":"Orlando",
                        "state":"FL",
                        "country":    "United States"
                     },
                     {
                        "prefix":"1312",
                        "city":"Chicago",
                        "state":"IL",
                            "country":"United States"
                     },
                     {
                        "prefix":"1303",
                        "city":"Denver",
                            "state":"CO",
                        "country":"United States"
                     },
                     {
                        "prefix":"1310",
                        "city":    "Los Angeles",
                        "state":"CA",
                        "country":"United States"
                     },
                     {
                        "prefix":    "1412",
                        "city":"Pittsburgh",
                        "state":"PA",
                        "country":    "United States"
                     },
                     {
                        "prefix":"1415",
                        "city":"San Francisco",
                        "state":    "CA",
                        "country":"United States"
                     },
                     {
                        "prefix":"1206",
                        "city":    "Seattle",
                        "state":"WA",
                        "country":"United States"
                     },
                     {
                        "prefix":    "1301",
                        "city":"Washington",
                        "state":"DC",
                        "country":    "United States"
                     }
                  ]'
    
    @new_user      = { 'user_id' => "12345", 'href' => "http://api.tropo.com/v1/users/12345", 'confirmation_key' => '1234' }
    @new_user_json = ActiveSupport::JSON.encode({ 'user_id' => "12345", 'href' => "http://api.tropo.com/v1/users/12345", 'confirmationKey' => '1234' })
    @existing_user = { "city"         => "Orlando", 
                       "address"      => "1234 Anywhere St", 
                       "href"         => "https://api-smsified-eng.voxeo.net/v1/users/12345", 
                       "lastName"     => "User", 
                       "address2"     => "Unit 1337", 
                       "joinDate"     => "2010-05-17T18:26:07.217+0000", 
                       "country"      => "USA", 
                       "username"     => "username", 
                       "phoneNumber"  => "4075551212", 
                       "id"           => "12345", 
                       "postalCode"   => "32801", 
                       "jobTitle"     => "Technical Writer", 
                       "firstName"    => "Tropo", 
                       "organization" => "Voxeo", 
                       "status"       => "active", 
                       "email"        => "support@tropo.com"}

    
    @list_account = { 'account_id' => "12345", 'href' => "http://api-eng.voxeo.net:8080/v1/users/12345" }
    
    @payment_method = { "rechargeAmount"    => "0.00", 
                        "paymentType"       => "https://api-smsified-eng.voxeo.net/v1/types/payment/1", 
                        "accountNumber"     => "5555", 
                        "paymentTypeName"   => "visa", 
                        "rechargeThreshold" => "0.00"}
                        
    @payment_methods = [ { "name" => "visa", 
                           "href" => "https://api-smsified-eng.voxeo.net/v1/types/payment/1", 
                           "id"   => "1"}, 
                         { "name" => "mastercard", 
                           "href" => "https://api-smsified-eng.voxeo.net/v1/types/payment/2", 
                           "id"   => "2"}, 
                         { "name" => "amex", 
                           "href" => "https://api-smsified-eng.voxeo.net/v1/types/payment/3", 
                           "id"   => "3"}]

    @features = [ { "name"        => "International Outbound SMS", 
                    "href"        => "https://api-smsified-eng.voxeo.net/v1/features/9", 
                    "id"          => "9", 
                    "description" => "International Outbound SMS" }, 
                  { "name"        => "Test Outbound SMS", 
                    "href"        => "https://api-smsified-eng.voxeo.net/v1/features/7", 
                    "id"          => "7", 
                    "description" => "Test Outbound SMS" }, 
                  { "name"        => "Domestic Outbound SMS", 
                    "href"        => "https://api-smsified-eng.voxeo.net/v1/features/8", 
                    "id"          => "8", 
                    "description" => "Domestic Outbound SMS" } ]
    
    @user_features = [ { "feature"     => "https://api-smsified-eng.voxeo.net/v1/features/7", 
                         "href"        => "https://api-smsified-eng.voxeo.net/v1/users/12345/features/7", 
                         "featureName" => "Test Outbound SMS" } ]
    
    @feature = { 'href' => 'http://api-smsified-eng.voxeo.net/v1/users/12345/features/8' }
    
    @feature_delete_message = { "message" => "disabled feature https://api-smsified-eng.voxeo.net/v1/features/8 for user https://api-smsified-eng.voxeo.net/v1/users/12345" }
    
    @bad_account_creds =  { "account-accesstoken-get-response" =>
                            { "accessToken"   => "", 
                              "statusMessage" => "Invalid login.", 
                              "statusCode"    => 403}}
                    
    # Register our resources
    
    # Applications with a bad uname/passwd
    FakeWeb.register_uri(:get, 
                         %r|http://bad:password@api.tropo.com/v1/applications|, 
                         :status => ["401", "Unauthorized"])

    # A specific application
    FakeWeb.register_uri(:get, 
                         "http://foo:bar@api.tropo.com/v1/applications/108000", 
                         :body => ActiveSupport::JSON.encode(@applications[0]),
                         :content_type => "application/json")
    
    # Applications
    FakeWeb.register_uri(:get, 
                         %r|http://foo:bar@api.tropo.com/v1/applications|, 
                         :body => ActiveSupport::JSON.encode(@applications), 
                         :content_type => "application/json")
                         
    # Create an application       
    FakeWeb.register_uri(:post, 
                         %r|http://foo:bar@api.tropo.com/v1/applications|, 
                         :body => ActiveSupport::JSON.encode({ "href" => "http://api.tropo.com/v1/applications/108016" }),
                         :status => ["200", "OK"])
    
    # Update a specific application
    FakeWeb.register_uri(:put, 
                         %r|http://foo:bar@api.tropo.com/v1/applications/108000|, 
                         :body => ActiveSupport::JSON.encode({ "href" => "http://api.tropo.com/v1/applications/108016" }),
                         :status => ["200", "OK"])
    
    # Addresses
    FakeWeb.register_uri(:get, 
                         "http://foo:bar@api.tropo.com/v1/applications/108000/addresses", 
                         :body => ActiveSupport::JSON.encode(@addresses), 
                         :content_type => "application/json")
    
    # Get a specific address
    FakeWeb.register_uri(:get, 
                         "http://foo:bar@api.tropo.com/v1/applications/108000/addresses/number/883510001812716", 
                         :body => ActiveSupport::JSON.encode(@addresses[0]),
                         :content_type => "application/json")

    # Get a address that is an IM/username
    FakeWeb.register_uri(:get, 
                         "http://foo:bar@api.tropo.com/v1/applications/108000/addresses/jabber/xyz123", 
                         :body => ActiveSupport::JSON.encode(@addresses[2]), 
                         :content_type => "application/json")

    # Get a address that is a token
    FakeWeb.register_uri(:get, 
                         "http://foo:bar@api.tropo.com/v1/applications/108000/addresses/jabber/xyz123", 
                         :body => ActiveSupport::JSON.encode(@addresses[2]), 
                         :content_type => "application/json")
                                                
    # Get a address that is a Pin
    FakeWeb.register_uri(:post, 
                         "http://foo:bar@api.tropo.com/v1/applications/108000/addresses", 
                         :body => ActiveSupport::JSON.encode(@addresses[2]),
                         :content_type => "application/json")
                                                
    # Get a address that is a token
    FakeWeb.register_uri(:get, 
                         "http://foo:bar@api.tropo.com/v1/applications/108000/addresses/token/a1b2c3d4",
                         :body => ActiveSupport::JSON.encode(@addresses[4]), 
                         :content_type => "application/json")
                                                
    # Get a address that is a number
    FakeWeb.register_uri(:post, 
                         "http://foo:bar@api.tropo.com/v1/applications/108000/addresses", 
                         :body => ActiveSupport::JSON.encode({ "href" => "http://api.tropo.com/v1/applications/108000/addresses/number/7202551912" }), 
                         :content_type => "application/json")
    
    # Create a address that is an IM account               
    FakeWeb.register_uri(:post, 
                         "http://foo:bar@api.tropo.com/v1/applications/108001/addresses", 
                         :body => ActiveSupport::JSON.encode({ "href" => "http://api.tropo.com/v1/applications/108001/addresses/jabber/xyz123@bot.im" }), 
                         :content_type => "application/json")
    
     # Create a address that is a Token         
     FakeWeb.register_uri(:post, 
                          "http://foo:bar@api.tropo.com/v1/applications/108002/addresses", 
                          :body => ActiveSupport::JSON.encode({ "href" => "http://api.tropo.com/v1/applications/108002/addresses/token/12345679f90bac47a05b178c37d3c68aaf38d5bdbc5aba0c7abb12345d8a9fd13f1234c1234567dbe2c6f63b" }), 
                          :content_type => "application/json")
                          
    # Delete an application      
    FakeWeb.register_uri(:delete, 
                         "http://foo:bar@api.tropo.com/v1/applications/108000", 
                         :body => ActiveSupport::JSON.encode({ 'message' => 'delete successful' }), 
                         :content_type => "application/json",
                         :status => ["200", "OK"])

    # Exchanges
    FakeWeb.register_uri(:get, 
                         "http://foo:bar@api.tropo.com/v1/exchanges", 
                         :body => @exchanges, 
                         :status => ["200", "OK"],
                         :content_type => "application/json")

    # Delete a address
    FakeWeb.register_uri(:delete, 
                         "http://foo:bar@api.tropo.com/v1/applications/108000/addresses/number/883510001812716", 
                         :body => ActiveSupport::JSON.encode({ 'message' => 'delete successful' }), 
                         :content_type => "application/json",
                         :status => ["200", "OK"])
    
    # Add a specific address
    FakeWeb.register_uri(:post, 
                         "http://foo:bar@api.tropo.com/v1/applications/108002/addresses/number/883510001812716", 
                         :body => ActiveSupport::JSON.encode({ 'message' => 'delete successful' }), 
                         :content_type => "application/json",
                         :status => ["200", "OK"])
    
   # Create a new user
   FakeWeb.register_uri(:post, 
                        "http://foo:bar@api.tropo.com/v1/users", 
                        :body => @new_user_json, 
                        :content_type => "application/json",
                        :status => ["200", "OK"])

   # Get a specific user
   FakeWeb.register_uri(:get, 
                        "http://foo:bar@api.tropo.com/v1/users/12345", 
                        :body => ActiveSupport::JSON.encode(@existing_user), 
                        :content_type => "application/json",
                        :status => ["200", "OK"])
                                              
   # Confirm an account account
   FakeWeb.register_uri(:post, 
                        "http://foo:bar@api.tropo.com/v1/users/12345/confirmations", 
                        :body => ActiveSupport::JSON.encode({"message" => "successfully confirmed user 12345" }), 
                        :content_type => "application/json",
                        :status => ["200", "OK"])
                        
   # Return the payment method configured for a user
   FakeWeb.register_uri(:get, 
                        "http://foo:bar@api.tropo.com/v1/users/12345/payment/method", 
                        :body => ActiveSupport::JSON.encode(@payment_method), 
                        :content_type => "application/json",
                        :status => ["200", "OK"])                      

   # Return payment types
   FakeWeb.register_uri(:get, 
                        "http://foo:bar@api.tropo.com/v1/types/payment", 
                        :body => ActiveSupport::JSON.encode(@payment_methods), 
                        :content_type => "application/json",
                        :status => ["200", "OK"])
   
   # Return features
   FakeWeb.register_uri(:get, 
                        "http://foo:bar@api.tropo.com/v1/features", 
                        :body => ActiveSupport::JSON.encode(@features), 
                        :content_type => "application/json",
                        :status => ["200", "OK"])                                          

   # Return features for a user
   FakeWeb.register_uri(:get, 
                        "http://foo:bar@api.tropo.com/v1/users/12345/features", 
                        :body => ActiveSupport::JSON.encode(@user_features), 
                        :content_type => "application/json",
                        :status => ["200", "OK"])

  # Add a feature to a user
  FakeWeb.register_uri(:post, 
                       "http://foo:bar@api.tropo.com/v1/users/12345/features", 
                       :body => ActiveSupport::JSON.encode(@feature), 
                       :content_type => "application/json",
                       :status => ["200", "OK"])
                                                    
  # Add a feature to a user
  FakeWeb.register_uri(:delete, 
                       "http://foo:bar@api.tropo.com/v1/users/12345/features/8", 
                       :body => ActiveSupport::JSON.encode(@feature_delete_message), 
                       :content_type => "application/json",
                       :status => ["200", "OK"])
                       
   # List an account, with bad credentials
   FakeWeb.register_uri(:get, 
                        "http://evolution.voxeo.com/api/account/accesstoken/get.jsp?username=foobar7474&password=fooeyfooey", 
                        :body => ActiveSupport::JSON.encode(@bad_account_creds), 
                        :content_type => "application/json",
                        :status => ["403", "Invalid Login."])
  end
  
  before(:each) do      
    @tropo_provisioning = TropoProvisioning.new('foo', 'bar')
  end
  
  it "should create a TropoProvisioning object" do
    @tropo_provisioning.instance_of?(TropoProvisioning).should == true
  end
  
  it "should get an unathorized back if there is an invalid username or password" do
    bad_credentials = TropoProvisioning.new('bad', 'password')
    begin
      response = bad_credentials.applications
    rescue => e
      e.to_s.should == '401: Unauthorized - '
    end
  end
  
  it "should get a list of applications" do
    applications = []
    @applications.each { |app| applications << app.merge({ 'application_id' => app['href'].split('/').last }) }
    
    @tropo_provisioning.applications.should == applications
  end
  
  it "should get a specific application" do
    response = @tropo_provisioning.application '108000'
    response['href'].should == @applications[0]['href']
  end
  
  it "should raise ArgumentErrors if appropriate arguments are not specified" do
    begin
      @tropo_provisioning.create_application({ :foo => 'bar' })
    rescue => e
      e.to_s.should == ':name required'
    end
    
    begin
      @tropo_provisioning.create_application({ :name      => 'foobar',
                                               :partition => 'foobar',
                                               :platform  => 'foobar' })
    rescue => e
      e.to_s.should == ':messagingUrl or :voiceUrl required'
    end
  end
  
  it "should raise ArgumentErrors if appropriate values are not passed" do
    begin
      @tropo_provisioning.create_application({ :name         => 'foobar',
                                               :partition    => 'foobar',
                                               :platform     => 'foobar',
                                               :messagingUrl => 'http://foobar' })
    rescue => e
      e.to_s.should == ":platform must be 'scripting' or 'webapi'"
    end
    
    begin
      @tropo_provisioning.create_application({ :name         => 'foobar',
                                               :partition    => 'foobar',
                                               :platform     => 'scripting',
                                               :messagingUrl => 'http://foobar' })
    rescue => e
      e.to_s.should == ":partiion must be 'staging' or 'production'"
    end
  end
  
  it "should receive an href back when we create a new application receiving an href back" do
    # With camelCase
    result = @tropo_provisioning.create_application({ :name         => 'foobar',
                                                      :partition    => 'production',
                                                      :platform     => 'scripting',
                                                      :messagingUrl => 'http://foobar' })
    result.href.should == "http://api.tropo.com/v1/applications/108016"
    result.application_id.should == '108016'
    
    # With underscores
    result = @tropo_provisioning.create_application({ :name          => 'foobar',
                                                      :partition     => 'production',
                                                      :platform      => 'scripting',
                                                      :messaging_url => 'http://foobar' })
    result.href.should == "http://api.tropo.com/v1/applications/108016"
    result.application_id.should == '108016'
  end
  
  it "should receive an href back when we update an application receiving an href back" do
    # With camelCase
    result = @tropo_provisioning.update_application('108000', { :name         => 'foobar',
                                                                :partition    => 'production',
                                                                :platform     => 'scripting',
                                                                :messagingUrl => 'http://foobar' })
    result.href.should == "http://api.tropo.com/v1/applications/108016"
    
    # With underscore
    result = @tropo_provisioning.update_application('108000', { :name          => 'foobar',
                                                                :partition     => 'production',
                                                                :platform      => 'scripting',
                                                                :messaging_url => 'http://foobar' })
    result.href.should == "http://api.tropo.com/v1/applications/108016"
  end
  
  it "should delete an application" do
    result = @tropo_provisioning.delete_application('108000')
    result.message.should == 'delete successful'
  end
  
  it "should list all of the addresses available for an application" do
    result = @tropo_provisioning.addresses('108000')
    result.should == @addresses
  end
  
  it "should list a single address when requested with a number for numbers" do
    result = @tropo_provisioning.address('108000', '883510001812716')
    result.should == @addresses[0]
  end
  
  it "should list a single address of the appropriate type when requested" do
    # First a number
    result = @tropo_provisioning.address('108000', '883510001812716')
    result.should == @addresses[0]
    
    # Then an IM username
    result = @tropo_provisioning.address('108000', 'xyz123')
    result.should == @addresses[2]
    
    # Then a pin
    result = @tropo_provisioning.address('108000', '9991436300')
    result.should == @addresses[3]
    
    # Then a token
    result = @tropo_provisioning.address('108000', 'a1b2c3d4')
    result.should == @addresses[4]
  end
  
  it "should generate an error of the addition of the address does not have a required field" do
    # Add a address without a type
    begin
      @tropo_provisioning.create_address('108000')
    rescue => e
      e.to_s.should == ":type required"
    end
    
    # Add a number without a prefix
    begin
      @tropo_provisioning.create_address('108000', { :type => 'number' })
    rescue => e
      e.to_s.should == ":prefix required to add a number address"
    end
    
    # Add a jabber without a username
    begin
      @tropo_provisioning.create_address('108000', { :type => 'jabber' })
    rescue => e
      e.to_s.should == ":username required"
    end
    
    # Add an aim without a password
    begin
      @tropo_provisioning.create_address('108000', { :type => 'aim', :username => 'joeblow@aim.com' })
    rescue => e
      e.to_s.should == ":password and required"
    end
    
    # Add a token without a channel
    begin
      @tropo_provisioning.create_address('108000', { :type => 'token' })
    rescue => e
      e.to_s.should == ":channel required"
    end
    
    # Add a token with an invalid channel type
    begin
      @tropo_provisioning.create_address('108000', { :type => 'token', :channel => 'BBC' })
    rescue => e
      e.to_s.should == ":channel must be voice or messaging"
    end
  end
  
  it "should add appropriate addresses" do  
    # Add a address based on a prefix
    result = @tropo_provisioning.create_address('108000', { :type => 'number', :prefix => '1303' })
    result[:href].should == "http://api.tropo.com/v1/applications/108000/addresses/number/7202551912"
    result[:address].should == '7202551912'
    
    # Add a jabber account
    result = @tropo_provisioning.create_address('108001', { :type => 'jabber', :username => 'xyz123@bot.im' })
    result[:href].should == "http://api.tropo.com/v1/applications/108001/addresses/jabber/xyz123@bot.im"
    result[:address].should == 'xyz123@bot.im' 
    
    # Add a token
    result = @tropo_provisioning.create_address('108002', { :type => 'token', :channel => 'voice' })
    result[:href].should == "http://api.tropo.com/v1/applications/108002/addresses/token/12345679f90bac47a05b178c37d3c68aaf38d5bdbc5aba0c7abb12345d8a9fd13f1234c1234567dbe2c6f63b"
    result[:address].should == '12345679f90bac47a05b178c37d3c68aaf38d5bdbc5aba0c7abb12345d8a9fd13f1234c1234567dbe2c6f63b'
  end
  
  it "should obtain a list of available exchanges" do
    results = @tropo_provisioning.exchanges
    results.should == ActiveSupport::JSON.decode(@exchanges)
  end
  
  it "should delete a address" do
    result = @tropo_provisioning.delete_address('108000', '883510001812716')
    result[:message].should == "delete successful"
  end
  
  it "should raise an ArgumentError if the right params are not passed to move_address" do
    begin
      @tropo_provisioning.move_address({ :to => '108002', :address => '883510001812716'})
    rescue => e
      e.to_s.should == ':from is required'
    end
    
    begin
      @tropo_provisioning.move_address({ :from => '108002', :address => '883510001812716'})
    rescue => e
      e.to_s.should == ':to is required'
    end
    
    begin
      @tropo_provisioning.move_address({ :from => '108002', :to => '883510001812716'})
    rescue => e
      e.to_s.should == ':address is required'
    end
  end
  
  it "should move a address" do
    results = @tropo_provisioning.move_address({ :from => '108000', :to => '108002', :address => '883510001812716'})
    results.should == { 'message' => 'delete successful' }
  end
  
  it "should provide a token for an existing account" do
    pending('Need to work on tests for the new account')
    result = @tropo_provisioning.account("foobar7474", 'fooey')
    result.should == @list_account
  end
  
  it "should not provide a token for an existing account if wrong credentials" do
    pending('Need to work on tests for the new account')
    begin
      result = @tropo_provisioning.account("foobar7474", 'fooeyfooey')
    rescue => e
      e.to_s.should == "403 - Invalid Login."
    end
  end
  
  it "should return accounts with associated addresses" do
    pending()
    result = @tropo_provisioning.account_with_addresses('108000')
    result.should == nil
    
    result = @tropo_provisioning.accounts_with_addresses
    result.should == nil
  end
  
  it "should raise argument errors on create_user if required params not passed" do
    begin
      @tropo_provisioning.create_user
    rescue => e
      e.to_s.should == ':username required'
    end
    
    begin
      @tropo_provisioning.create_user({ :username => "foobar7474" })
    rescue => e
      e.to_s.should == ':password required'
    end
    
    begin
      @tropo_provisioning.create_user({ :username => "foobar7474", :password => 'fooey' })
    rescue => e
      e.to_s.should == ':email required'
    end
  end
    
  it "should create a new user" do
    result = @tropo_provisioning.create_user({ :username => "foobar7474", :password => 'fooey', :email => 'jsgoecke@voxeo.com' })
    result.should == @new_user
  end
  
  it "should confirm a user" do
    result = @tropo_provisioning.confirm_user('12345', '1234', '127.0.0.1')
    result.message.should == "successfully confirmed user 12345"
  end
  
  it "should obtain details about a user" do
    result = @tropo_provisioning.user('12345')
    result.should == @existing_user
  end
  
  it "should get the payment method for a user" do
    result = @tropo_provisioning.user_payment_method('12345')
    result.should == @payment_method
  end
  
  it "should return a list of available payment types" do
    result = @tropo_provisioning.available_payment_types
    result.should == @payment_methods
  end
  
  it "should return a list of available features" do
    result = @tropo_provisioning.features
    result.should == @features
  end
  
  it "should return a list of features configured for a user" do
    result = @tropo_provisioning.user_features('12345')
    result.should == @user_features
  end
  
  it "should add a feature to a user" do
    result = @tropo_provisioning.user_enable_feature('12345', 'http://api-smsified-eng.voxeo.net/v1/features/8')
    result.should == @feature
  end
  
  it "should disable a feature for a user" do
    result = @tropo_provisioning.user_disable_feature('12345', '8')
    result.should == @feature_delete_message
  end
end