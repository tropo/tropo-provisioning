
##
# Models an error while accessing the Tropo provisioning API
class TropoError < RuntimeError
  attr_reader :http_status
  
  ##
  # Initializer
  def initialize(http_status = '500')
    @http_status = http_status
  end
end