require 'rubygems'
require 'lib/tropo-provisioning'

config = YAML.load(File.open('examples/config.yml'))
app_details = YAML.load(File.open("examples/#{config['filename']}"))

# Create a new provisioning object with your Tropo credentials
provisioning = TropoProvisioning.new(config['tropo']['username'], config['tropo']['password'], { :base_uri => 'http://api-smsified-eng.voxeo.net/v1'})

p provisioning.create_invitation({ :code   => 'ABC457',
                                   :count  => 100,
                                   :credit => 10 })