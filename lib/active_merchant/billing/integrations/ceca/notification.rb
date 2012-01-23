# encoding: utf-8
module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Ceca
        class Notification < ActiveMerchant::Billing::Integrations::Notification
          include PostsData

          NotifySignatureFields = ["MerchantID", "AcquirerBIN", "TerminalID", "Num_operacion",
            "Importe", "TipoMoneda", "Exponente", "Referencia"]


          # Notifications are only send for successful payments
          def status
            'Completed'
          end

          def complete?
            status == 'Completed'
          end 

          # When was this payment received by the client. 
          def received_at
            @received_at ||= Time.zone.now
          end

          # the money amount we received in cents in X.2 format
          def gross
            "%d.%02d" % [ gross_cents / 100, gross_cents % 100 ]
          end

          def gross_cents
            params['Importe'].to_i
          end


          def currency
            Ceca.currency_from_code(currency_code)
          end

          def language
            Ceca.language_from_code(language_code)
          end


          { :order => 'Num_operacion', :description => 'Descripcion', :currency_code => 'TipoMoneda',
            :language_code => 'Idioma', :country_code => 'Pais', :reference => 'Referencia',
            :authorization_number => 'Num_aut', :signature => "Firma" }.each do |method, field|

            
            class_eval "def #{method}; params['#{field}']; end"
          end


          # Acknowledge the transaction.
          #
          # Validate the details provided by the gateway by ensuring that the signature
          # matches up with the details provided.
          #
          # Optionally, a set of credentials can be provided that should contain a 
          # :secret_key instead of using the global credentials defined in the Ceca::Helper.
          #
          # Example:
          # 
          #   def notify
          #     notify = Ceca::Notification.new(request.query_parameters)
          #
          #     if notify.acknowledge
          #       ... process order ... if notify.complete?
          #     else
          #       ... log possible hacking attempt ...
          #     end
          #
          #
          def acknowledge
            sign = signature
            sign.present? && sign == calculated_sign
          end

          private

          def calculated_sign
            Ceca.sing_values params.values_at(*NotifySignatureFields)
          end

          # Take the posted data and try to extract the parameters.
          #
          # Posted data can either be a parameters hash or CGI data string
          # of parameters.
          #
          def parse(post)
            if post.is_a?(Hash)
              post.each {|key, value| params[key] = value }
            else
              super
            end
            @raw = post.inspect.to_s
          end
 
        end
      end
    end
  end
end
