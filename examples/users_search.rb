require 'rubygems'
require 'yaml'
require 'lib/tropo-provisioning'
require 'json'

config = YAML.load(File.open('examples/config.yml'))

# Create a new provisioning object with your Tropo credentials
provisioning = TropoProvisioning.new(config['tropo']['username'], config['tropo']['password'], :base_uri => 'http://api.smsified.com/v1')

# Create an account
p provisioning.search_users 'username=jsg'

p provisioning.username_exists? 'jsgoecke'
p provisioning.username_exists? 'fooeyfooy'