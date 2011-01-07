require 'rubygems'
require 'yaml'
require 'lib/tropo-provisioning'

config = YAML.load(File.open('examples/config.yml'))

# Create a new provisioning object with your Tropo credentials
provisioning = TropoProvisioning.new(config['tropo']['username'], config['tropo']['password'], :base_uri => 'http://api-smsified-eng.voxeo.net/v1')

Create an account
r = provisioning.create_user({ :username   => 'foobar' + rand(10000).to_s, 
                               :first_name => 'Count',
                               :last_name  => 'Dracula',
                               :password   => 'test124',
                               :email      => 'jsgoecke@voxeo.com',
                               :status     => 'active' })

p r

p provisioning.confirm_user(r['user_id'], r['confirmation_key'], '127.0.0.1')

#p provisioning.modify_user('54238', { :first_name => 'Dolly' })