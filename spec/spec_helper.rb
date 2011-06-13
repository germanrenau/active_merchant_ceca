# encoding: utf-8
require "bundler/setup"

#$:.unshift File.expand_path('../../lib', __FILE__)

require 'spec'
# require 'spec/rails'
require 'money'
require 'yaml'
require 'active_merchant_ceca'

require 'action_controller'
# require 'action_view/template'
# begin
#   require 'action_dispatch/testing/test_process'
# rescue LoadError
#   require 'action_controller/test_process'
# end
require 'active_merchant/billing/integrations/action_view_helper'

ActiveMerchant::Billing::Base.mode = :test

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

Spec::Runner.configure do |config|
  #config.fixture_path = "#{::Rails.root}/spec/fixtures"

  #config.include Devise::TestHelpers, :type => :controller
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, comment the following line or assign false
  # instead of true.
  #config.use_transactional_fixtures = true
end
