require 'rubygems'
require 'yaml'
require 'lib/tropo-provisioning'

config = YAML.load(File.open('examples/config.yml'))

# Create a new provisioning object with your Tropo credentials
provisioning = TropoProvisioning.new(config['tropo']['username'], config['tropo']['password'], :base_uri => 'http://172.16.10.125:8080/provisioning')

# Create an account
p provisioning.create_account({ :username => 'foobar' + rand(10000).to_s, 
                                :password => 'test124',
                                :email    => 'jsgoecke@voxeo.com',
                                :ip       => '98.207.5.162',
                                :website  => 'smsified',
                                :company_branding_id => '13' })

