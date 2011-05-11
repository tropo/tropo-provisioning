require 'rubygems'
require 'lib/tropo-provisioning'

config = YAML.load(File.open('examples/config.yml'))
app_details = YAML.load(File.open("examples/#{config['filename']}"))

# Create a new provisioning object with your Tropo credentials
provisioning = TropoProvisioning.new(config['tropo']['username'], config['tropo']['password'], { :base_uri => 'http://api-smsified-eng.voxeo.net/v1'})

# Then you may iterate through all of your configured addresses
provisioning.invitations.each do |invitation|
  p invitation
end

p provisioning.invitation('ABC456')

p provisioning.user_invitations '15909'

p provisioning.user_invitation '15909', 'ABC456'