
require 'active_merchant'

module ActiveMerchant
  module Billing
    module Integrations
      autoload :Ceca, 'active_merchant/billing/integrations/ceca'
    end
  end
end
