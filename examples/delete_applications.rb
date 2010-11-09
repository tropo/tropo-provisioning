## WARNING ##
# IF YOU RUN THIS SCRIPT, IT WILL DELETE ALL OF YOUR APPLICATIONS #
## WARNING ##

require 'rubygems'
require 'lib/tropo-provisioning'

config = YAML.load(File.open('examples/config.yml'))

# Create a new provisioning object with your Tropo credentials
provisioning = TropoProvisioning.new(config['tropo']['username'], 
                                     config['tropo']['password'], 
                                     :base_uri => 'http://api.tropo.com/provisioning')
                                     
applications = provisioning.applications

p applications

applications.each do |app|
  provisioning.delete_application(app.application_id)
end

## WARNING ##
# IF YOU RUN THIS SCRIPT, IT WILL DELETE ALL OF YOUR APPLICATIONS #
## WARNING ##
