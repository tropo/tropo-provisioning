require 'rubygems'
require 'lib/tropo-provisioning'

config = YAML.load(File.open('examples/config.yml'))
app_details = YAML.load(File.open("examples/#{config['filename']}"))

# Create a new provisioning object with your Tropo credentials
provisioning = TropoProvisioning.new(config['tropo']['username'], config['tropo']['password'])

# Then you may iterate through all of your configured applications
provisioning.applications_with_addresses.each do |app|
  p app
  puts '*'*10
end

# Now list a single application
p '<===============>'
p provisioning.application_with_address('124780')