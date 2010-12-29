require 'rubygems'
require 'yaml'
require 'lib/tropo-provisioning'

config = YAML.load(File.open('examples/config.yml'))

# Create a new provisioning object with your Tropo credentials
provisioning = TropoProvisioning.new(config['tropo']['username'], config['tropo']['password'], :base_uri => 'http://api-smsified-eng.voxeo.net/v1')

# List availble features
p provisioning.features

# List features configured for a user
p provisioning.user_features('54228')