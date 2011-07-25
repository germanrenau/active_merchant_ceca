# encoding: utf-8
module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      # See the BbvaTpv::Helper class for more generic information on usage of
      # this integrated payment method.
      module Ceca
        autoload :Helper, 'active_merchant/billing/integrations/ceca/helper.rb'
        autoload :Return, 'active_merchant/billing/integrations/ceca/return.rb'
        autoload :Notification, 'active_merchant/billing/integrations/ceca/notification.rb'

        EXPONENT_FIELD = "2"
        ENCRYPTION_FIELD = "SHA1"
        SUPPORTED_PAYMENT_FIELD = "SSL"

        SUPPORTED_LANGUAGES = [ 
          [:es, "01"],
          [:ca, "02"],
          [:eu, "03"],
          [:gl, "04"],
          [:va, "05"],
          [:en, "06"],
          [:fr, "07"],
          [:de, "08"],
          [:pt, "09"], 
          [:it, "10"] ]

#        SUPPORTED_TRANSACTIONS = [
#          [:authorization,              '0'],
#          [:preauthorization,           '1'],
#          [:confirmation,               '2'],
#          [:automatic_return,           '3'],
#          [:reference_payment,          '4'],
#          [:recurring_transaction,      '5'],
#          [:successive_transaction,     '6'],
#          [:authentication,             '7'],
#          [:confirm_authentication,     '8'],
#          [:cancel_preauthorization,    '9'],
#          [:deferred_authorization,             'O'],
#          [:confirm_deferred_authorization,     'P'],
#          [:cancel_deferred_authorization,      'Q'],
#          [:inicial_recurring_authorization,    'R'],
#          [:successive_recurring_authorization, 'S'] ]
        
        SUPPORTED_CURRENCIES = [ ['EUR', '978'] ]


        RESPONSE_CODES = [
          [0,   "OPERACIÓN AUTORIZADA"],
          [1,   "COMUNICACION ON-LINE INCORRECTA"],
          [2,   "ERROR AL CALCULAR FIRMA"],
          [13,  "OPERACION INCORRECTA"],
          [190, "Operación no realizable"],
          [400, "Anulación aceptada"],
          [900, "Devolución aceptada"]
        ]



        mattr_accessor :service_test_url
        self.service_test_url = "http://tpv.ceca.es:8000/cgi-bin/tpv"
        mattr_accessor :service_production_url
        self.service_production_url = "https://pgw.ceca.es/cgi-bin/tpv"

        mattr_accessor :operations_test_url
        self.operations_test_url = "http://tpv.ceca.es:8000/cgi-bin/tpvanular"
        mattr_accessor :operations_production_url
        self.operations_production_url = "https://pgw.ceca.es/cgi-bin/tpvanular"

        
        mattr_accessor :production_encryption_key, :test_encryption_key 
        mattr_accessor :acquirer_bin, :terminal_id, :merchant_id
        mattr_accessor :default_success_url, :default_failure_url, :default_currency, :default_language


        def self.service_url 
          mode = ActiveMerchant::Billing::Base.integration_mode
          case mode
          when :production
            self.service_production_url
          when :test
            self.service_test_url
          else
            raise StandardError, "Integration mode set to an invalid value: #{mode}"
          end
        end

        def self.operations_url
          mode = ActiveMerchant::Billing::Base.integration_mode
          case mode
          when :production
            self.operations_production_url
          when :test
            self.operations_test_url
          else
            raise StandardError, "Integration mode set to an invalid value: #{mode}"
          end
        end

        def self.encryption_key
          mode = ActiveMerchant::Billing::Base.integration_mode
          case mode
          when :production
            self.production_encryption_key
          when :test
            self.test_encryption_key
          else
            raise StandardError, "Integration mode set to an invalid value: #{mode}"
          end
        end


        def self.currency_code( name )
          row = SUPPORTED_CURRENCIES.assoc(name)
          row.nil? ? SUPPORTED_CURRENCIES.first[1] : row[1]
        end

        def self.currency_from_code( code )
          row = SUPPORTED_CURRENCIES.rassoc(code)
          row.nil? ? SUPPORTED_CURRENCIES.first[0] : row[0]
        end

        def self.language_code(name)
          row = SUPPORTED_LANGUAGES.assoc(name.to_s.downcase.to_sym)
          row.nil? ? SUPPORTED_LANGUAGES.first[1] : row[1]
        end

        def self.language_from_code( code )
          row = SUPPORTED_LANGUAGES.rassoc(code)
          row.nil? ? SUPPORTED_LANGUAGES.first[0] : row[0]
        end


        def self.response_message_from_code(code)
          row = RESPONSE_CODES.assoc(code.to_i)
          row.nil? ? "ERROR" : row[1]
        end


#        def self.transaction_code(name)
#          row = SUPPORTED_TRANSACTIONS.assoc(name.to_sym)
#          row.nil? ? SUPPORTED_TRANSACTIONS.first[1] : row[1]
#        end
#
#        def self.transaction_from_code(code)
#          row = SUPPORTED_TRANSACTIONS.rassoc(code.to_s)
#          row.nil? ? SUPPORTED_TRANSACTIONS.first[0] : row[0]
#        end

      end
    end
  end
end
