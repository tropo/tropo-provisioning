class ProvisioningApiRuntimeError < RuntimeError
  attr_reader :http_status
  
  def initialize(http_status)
    @http_status = http_status
  end
end