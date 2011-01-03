require 'rubygems'
require 'yaml'
require 'lib/tropo-provisioning'
require 'json'

config = YAML.load(File.open('examples/config.yml'))

# Create a new provisioning object with your Tropo credentials
provisioning = TropoProvisioning.new(config['tropo']['username'], config['tropo']['password'], :base_uri => 'http://api-smsified-eng.voxeo.net/v1')

# Create an account
p provisioning.partitions
p provisioning.platforms('staging')


