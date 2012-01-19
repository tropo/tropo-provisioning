require 'spec_helper'

describe "TropoProvisioning" do
  
  let(:existing_user) do
    { "city"         => "Orlando", 
      "address"      => "1234 Anywhere St", 
      "href"         => "https://api-smsified-eng.voxeo.net/v1/users/12345", 
      "lastName"     => "User", 
      "address2"     => "Unit 1337", 
      "joinDate"     => "2010-05-17T18:26:07.217+0000", 
      "country"      => "USA", 
      "username"     => "foo", 
      "phoneNumber"  => "4075551212", 
      "id"           => "12345", 
      "postalCode"   => "32801", 
      "jobTitle"     => "Technical Writer", 
      "firstName"    => "Tropo", 
      "organization" => "Voxeo", 
      "status"       => "active", 
      "email"        => "support@tropo.com"
    }
  end
  
  let(:exchanges) do
    '[
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
  end
  
  let(:application) do
    { "voiceUrl"    => "http://webhosting.voxeo.net/1234/www/simple.js", 
                        "name"         => "API Test", 
                        "href"         => "http://api.tropo.com/v1/applications/108000", 
                        "partition"    => "staging", 
                        "platform"     => "scripting" }
  end

  let(:tropo_provisioning) do      
    TropoProvisioning.new('jsgoecke', 'test123')
  end
  
  let(:app_details) do
    { :voiceUrl     => 'http://mydomain.com/voice_script.rb',
       :partition    => 'staging',
       :messagingUrl => 'http://mydomain.com/message_script.rb',
       :platform     => 'scripting' }
  end
  
  it "should create an application" do
    # Get a specific user by username
    FakeWeb.register_uri(:get, 
                         "https://#{USERNAME}:#{PASSWORD}@api.tropo.com/v1/users/jsgoecke",
                         :body => ActiveSupport::JSON.encode(existing_user), 
                         :content_type => "application/json",
                         :status => ["200", "OK"])

    # Create an application       
    FakeWeb.register_uri(:post, 
                         %r|https://#{USERNAME}:#{PASSWORD}@api.tropo.com/v1/applications|, 
                         :body => ActiveSupport::JSON.encode({ "href" => "http://api.tropo.com/provisioning/applications/#{APPLICATION_ID}" }),
                         :status => ["200", "OK"])
    
    
    result = tropo_provisioning.create_application(app_details.merge!({ :name => 'Live API Test' }))
    result.href.should =~ /^http:\/\/api.tropo.com\/provisioning\/applications\/\d{1,7}$/
    result.application_id.should =~ /\d{1,7}/
    result.application_id.should.eql?(APPLICATION_ID)
  end
  
  it "should get a list of exchanges" do
    # Exchanges
    FakeWeb.register_uri(:get, 
                         "https://#{USERNAME}:#{PASSWORD}@api.tropo.com/v1/exchanges", 
                         :body => exchanges, 
                         :status => ["200", "OK"],
                         :content_type => "application/json")
    
    exchanges = tropo_provisioning.exchanges
    exchanges[0].city.should eql('Orlando')
  end
  
  it "should add a phone, IM and token address to the application" do  
    # Get a specific user by username
    FakeWeb.register_uri(:get, 
                         "https://#{USERNAME}:#{PASSWORD}@api.tropo.com/v1/users/jsgoecke",
                         :body => ActiveSupport::JSON.encode(existing_user), 
                         :content_type => "application/json",
                         :status => ["200", "OK"])

    # Exchanges
    FakeWeb.register_uri(:get, 
                        "https://#{USERNAME}:#{PASSWORD}@api.tropo.com/v1/exchanges", 
                        :body => exchanges, 
                        :status => ["200", "OK"],
                        :content_type => "application/json")

    # Get a address that is a number
    FakeWeb.register_uri(:post, 
                         "https://#{USERNAME}:#{PASSWORD}@api.tropo.com/v1/applications/108016/addresses", 
                         :body => ActiveSupport::JSON.encode({ "href" => "http://api.tropo.com/v1/applications/108000/addresses/number/7202551912" }), 
                         :content_type => "application/json")
    
    result = tropo_provisioning.create_address(APPLICATION_ID, { :type => 'number', :prefix => tropo_provisioning.exchanges[0].prefix })
    result.href.should =~ /http:\/\/api.tropo.com\/v1\/applications\/\d{1,7}\/addresses\/number\/\d{1,20}/
    
  end
  
  it "should add an IM token address to the application" do 
    # Get a specific user by username
    FakeWeb.register_uri(:get, 
                         "https://#{USERNAME}:#{PASSWORD}@api.tropo.com/v1/users/jsgoecke",
                         :body => ActiveSupport::JSON.encode(existing_user), 
                         :content_type => "application/json",
                         :status => ["200", "OK"])

    # Exchanges
    FakeWeb.register_uri(:get, 
                        "https://#{USERNAME}:#{PASSWORD}@api.tropo.com/v1/exchanges", 
                        :body => exchanges, 
                        :status => ["200", "OK"],
                        :content_type => "application/json")

    # Get a address that is a number
    FakeWeb.register_uri(:post, 
                         "https://#{USERNAME}:#{PASSWORD}@api.tropo.com/v1/applications/#{APPLICATION_ID}/addresses", 
                         :body => ActiveSupport::JSON.encode({ "href" => "http://api.tropo.com/v1/applications/#{APPLICATION_ID}/addresses/jabber/appsdsdsdasd@bot.im" }), 
                         :content_type => "application/json")
                         
    result = tropo_provisioning.create_address(APPLICATION_ID, { :type => 'jabber', :username => "liveapitest#{rand(100000).to_s}@bot.im" } )
    result.href.should =~ /http:\/\/api.tropo.com\/v1\/applications\/#{APPLICATION_ID}\/addresses\/jabber\/\w{10,16}@bot.im/
    
  end

  it "should add a token to the application" do 
    # Get a specific user by username
    FakeWeb.register_uri(:get, 
                         "https://#{USERNAME}:#{PASSWORD}@api.tropo.com/v1/users/jsgoecke",
                         :body => ActiveSupport::JSON.encode(existing_user), 
                         :content_type => "application/json",
                         :status => ["200", "OK"])

    # Exchanges
    FakeWeb.register_uri(:get, 
                        "https://#{USERNAME}:#{PASSWORD}@api.tropo.com/v1/exchanges", 
                        :body => exchanges, 
                        :status => ["200", "OK"],
                        :content_type => "application/json")

    # Get a address that is a number
    FakeWeb.register_uri(:post, 
                         "https://#{USERNAME}:#{PASSWORD}@api.tropo.com/v1/applications/#{APPLICATION_ID}/addresses", 
                         :body => ActiveSupport::JSON.encode({ "href" => "http://api.tropo.com/v1/applications/#{APPLICATION_ID}/addresses/token/"+("w"*88) }), 
                         :content_type => "application/json")
    result = tropo_provisioning.create_address(APPLICATION_ID, { :type => 'token', :channel => 'voice' } )
    result.href.should =~ /http:\/\/api.tropo.com\/v1\/applications\/#{APPLICATION_ID}\/addresses\/token\/\w{88}/
  end
  
  it "should update the application" do
    # First, get the application in question
    
    # A specific application
    FakeWeb.register_uri(:get, 
                         "https://#{USERNAME}:#{PASSWORD}@api.tropo.com/v1/applications/#{APPLICATION_ID}", 
                         :body => ActiveSupport::JSON.encode(application),
                         :content_type => "application/json")
    
    app_data = tropo_provisioning.application(APPLICATION_ID)
    app_data['name'] = 'Live API Test Update'
    
    # Update a specific application
    FakeWeb.register_uri(:put, 
                         %r|https://#{USERNAME}:#{PASSWORD}@api.tropo.com/v1/applications/#{APPLICATION_ID}|, 
                         :body => ActiveSupport::JSON.encode({ "href" => "http://api.tropo.com/v1/applications/#{APPLICATION_ID}" }),
                         :status => ["200", "OK"])

    result = tropo_provisioning.update_application(APPLICATION_ID, app_data)
    result.href.should =~ /^http:\/\/api.tropo.com\/v1\/applications\/#{APPLICATION_ID}$/
  end
  
  it "should move a address to a new application and then back" do
    pending
    # Create an application       
    FakeWeb.register_uri(:post, 
                         %r|https://#{USERNAME}:#{PASSWORD}@api.tropo.com/v1/applications|, 
                         :body => ActiveSupport::JSON.encode({ "href" => "http://api.tropo.com/provisioning/applications/#{APPLICATION_ID}" }),
                         :status => ["200", "OK"])
    
    new_app = tropo_provisioning.create_application(app_details.merge!({ :name => 'Live API Test New' }))
    new_app.href.should =~ /^http:\/\/api.tropo.com\/provisioning\/applications\/\d{1,7}$/

    new_address = tropo_provisioning.create_address(new_app.application_id, { :type => 'number', :prefix => tropo_provisioning.exchanges[0]['prefix'] })
    
    # Update a specific application
    FakeWeb.register_uri(:post, 
                         %r|http://#{USERNAME}:#{PASSWORD}@api.tropo.com/v1/applications/#{APPLICATION_ID}/addresses|, 
                         :body => ActiveSupport::JSON.encode({ "href" => "http://api.tropo.com/v1/applications/#{APPLICATION_ID}" }),
                         :status => ["200", "OK"])

    result = tropo_provisioning.move_address({ :from    => APPLICATION_ID,
                                :to      => new_app,
                                :address => new_address.address })
    result.should == nil
    
    result = tropo_provisioning.move_address({ :from    => new_app,
                                :to      => APPLICATION_ID,
                                :address => new_address.address })
    result.should == nil    
  end
  
  # it "should delete the addresses of an application" do
  #   addresses = @tp.addresses(APPLICATION_ID)
  #   addresses.each do |address|
  #     result = @tp.delete_address(APPLICATION_ID, address['number']) if address['number']
  #     result.message.should == 'delete successful'
  #     result = @tp.delete_address(APPLICATION_ID, address['username']) if address['username']
  #     result.message.should == 'delete successful'
  #   end
  # end
  # 
  # it "should delete an application" do
  #   result = @tp.delete_application(APPLICATION_ID)
  #   result.message.should == 'delete successful'
  # end
end
