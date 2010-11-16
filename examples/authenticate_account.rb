require 'rubygems'
require 'yaml'
require 'lib/tropo-provisioning'

config = YAML.load(File.open('examples/config.yml'))

# Create a new provisioning object with your Tropo credentials
provisioning = TropoProvisioning.new(config['tropo']['username'], config['tropo']['password'], :base_uri => 'http://172.16.10.125:8080/provisioning')

# Create an account
p provisioning.authenticate_account('jsgoecke', 'test123')

