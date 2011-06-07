# encoding: utf-8
module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Ceca
        # CECA Spanish Virtual POS Gateway
        #
        # Support for the Spanish payment gateway provided by CECA,
        # one of the main providers in Spain to Banks and Cajas.
        #
        # Requires the :terminal_id, :commercial_id, and :secret_key to be set in the credentials
        # before the helper can be used. Credentials may be overwriten when instantiating the helper
        # if required or instead of the global variable. Optionally, the :key_type can also be set to 
        # either 'sha1_complete' or 'sha1_extended', where the later is the default case. This
        # is a configurable option in the CECA admin which you may or may not be able to access.
        # If nothing seems to work, try changing this.
        #
        # Ensure the gateway is configured correctly. Synchronization should be set to Asynchronous
        # and the parameters in URL option (Parámetros en las URLs) should be set to true unless
        # the notify_url is provided. During development on localhost ensuring this option is set
        # is especially important as there is no other way to confirm a successful purchase.
        #
        # Your view for a payment form might look something like the following:
        #
        #   <%= payment_service_for @transaction.id, 'Company name', :amount => @transaction.amount, :currency => 'EUR', :service => :ceca do |service| %>
        #     <% service.description     @sale.description %>
        #     <% service.customer_name   @sale.client.name %>
        #     <% service.notify_url      notify_sale_url(@sale) %>
        #     <% service.success_url     win_sale_url(@sale) %>
        #     <% service.failure_url     fail_sale_url(@sale) %>
        #    
        #     <%= submit_tag "PAY!" %>
        #   <% end %>
        #
        #
        # 
        class Helper < ActiveMerchant::Billing::Integrations::Helper
          include PostsData

          FormSignatureFields = ["MerchantID", "AcquiererBIN", "TerminalID", "Num_operacion", 
            "Importe", "TipoMoneda", "Exponente", "Cifrado", "URL_OK", "URL_NOK"]

          ReqSignatureFields = ["MerchantID", "AcquiererBIN", "TerminalID", "Num_operacion", 
            "Importe", "TipoMoneda", "Exponente", "Referencia", "Cifrado"]


          mapping :acquirer_id,    'AcquirerBIN'
          mapping :terminal_id,    'TerminalID'

          mapping :account,     'MerchantID'

          mapping :order,       'Num_operacion'
          mapping :description, 'Descripcion'

          mapping :currency,    'TipoMoneda'
          mapping :amount,      'Importe'

          mapping :success_url, 'URL_OK'
          mapping :failure_url, 'URL_NOK'

          mapping :signature,   'Firma'

          mapping :language,    'Idioma'

          mapping :reference,   'Referencia'

          #### Fixed fields ####
          mapping :exponent,          'Exponente'       # "2"
          mapping :encryption,        'Cifrado'         # "SHA1"
          mapping :supported_payment, 'Pago_soportado'  # "SSL"
          ########

          #### Specific Fields for notification ####
          mapping :auth_num,    'Num_aut'
          mapping :country,     'Pais'
          ########

          #### Specific Fields for sending customer's credit card info ####
          mapping :payment_type,    'Pago_elegido'    # "SSL" | ""
          mapping :pan,             'PAN'
          mapping :expiration_date, 'Caducidad'
          mapping :cvv2,            'CVV2'
          ########

          # ammount should always be provided in cents!
          def initialize(order, account, options = {})
            super(order, account, options)

            # Merchant Account specific fields
            self.account = Ceca.merchant_id unless @fields[mappings[:account]]
            self.acquirer_id = Ceca.acquirer_id unless @fields[mappings[:acquirer_bin]]
            self.terminal_id = Ceca.terminal_id unless @fields[mappings[:terminal_id]]

            # Fields with defaults
            self.currency = Ceca.default_currency unless @fields[mappings[:currency]]
            self.language = Ceca.default_language unless @fields[mappings[:language]]
            self.success_url = Ceca.default_success_url unless @fields[mappings[:success_url]]
            self.failure_url = Ceca.default_failure_url unless @fields[mappings[:failure_url]]

            # Fixed fields
            self.exponent = Ceca::EXPONENT_FIELD
            self.encryption = Ceca::ENCRYPTION_FIELD
            self.supported_payment = Ceca::SUPPORTED_PAYMENT_FIELD
          end

          def amount=(money)
            cents = money.respond_to?(:cents) ? money.cents : money
            if money.is_a?(String) || cents.to_i <= 0
              raise ArgumentError, 'money amount must be either a Money object or a positive integer in cents.'
            end
            add_field mappings[:amount], cents.to_i
          end

          def order=(order_num)
            order_num = order_id.to_s
            regexp = /^[A-Za-z0-9_\-]{1,50}$/
            raise "Invalid order number format! First 4 digits must be numbers" if order_id !~ regexp

            add_field mappings[:order], order_id
          end

          def currency=( value )
            add_field mappings[:currency], Ceca.currency_code(value) 
          end

          def language=(lang)
            add_field mappings[:language], Ceca.language_code(lang)
          end


          def form_fields 
            @fields.merge(mappings[:signature] => sign_form)
          end

          def request_fields 
            @fields.merge(mappings[:signature] => sign_request)
          end

          # Send a manual request for the currently prepared transaction.
          # This is an alternative to the normal view helper and is useful
          # for special types of transaction.
          def send_transaction
            body = build_cgi_request

            headers = { }
            headers['Content-Length'] = body.size.to_s
            headers['User-Agent'] = "Active Merchant -- http://activemerchant.org"
            headers['Content-Type'] = 'application/x-www-form-urlencoded'
  
            # Return the raw response data
            ssl_post(Ceca.operations_url, body, headers)
          end

          protected

          def build_cgi_request
            ActiveMerchant::PostData[request_fields].to_post_data
          end


          # Generate a signature authenticating the current request.
          # Values included in the signature are determined by the the type of 
          # transaction.
          def sign_form
            sign_for FormSignatureFields
          end

          def sign_request
            sign_for ReqSignatureFields
          end

          def sign_for sign_fields
            sign_str = Ceca::Helper.encryption_key + sign_fields.map {|f| @fields[f].to_s }.sum

            Digest::SHA1.hexdigest(sig_str)
          end

        end
      end
    end
  end
end
