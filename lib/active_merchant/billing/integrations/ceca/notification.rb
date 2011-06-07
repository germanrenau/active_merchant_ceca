# encoding: utf-8
module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Ceca
        class Notification < ActiveMerchant::Billing::Integrations::Notification
          include PostsData

          NotifySignatureFields = ["MerchantID", "AcquiererBIN", "TerminalID", "Num_operacion", 
            "Importe", "TipoMoneda", "Exponente", "Referencia"]


          def complete?
            status == 'Completed'
          end 

          def order
            params['Num_operacion']
          end

          # When was this payment received by the client. 
          def received_at
            Time.now
          end

          # the money amount we received in cents in X.2 format
          def gross
            "%d.%02d" % [ gross_cents / 100, gross_cents % 100 ]
          end

          def gross_cents
            params['Importe'].to_i
          end

          # Was this a test transaction?
          def test?
            false
          end

          def currency
            Ceca.currency_from_code( params['TipoMoneda'] ) 
          end

          # Status of transaction. List of possible values:
          # <tt>Completed</tt>
          # <tt>Failed</tt>
          def status
            case error_code.to_i
            when 0, 400, 900
              'Completed'
            else
              'Failed'
            end
          end

          def error_code
            params['Num_aut']
          end

          def error_message
            msg = Ceca.response_message_from_code(error_code)
            error_code.to_s + ' - ' + (msg.nil? ? 'Operación Aceptada' : msg)
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
            sign = params["Firma"]
            sign.present? && sign == calculated_sign
          end

          private

          def calculated_sign
            sign_str = Ceca.encryption_key + NotifySignatureFields.map {|f| params[f].to_s }.sum
            Digest::SHA1.hexdigest(sign_str)
          end

          # Take the posted data and try to extract the parameters.
          #
          # Posted data can either be a parameters hash or CGI data string
          # of parameters.
          #
          def parse(post)
            if post.is_a?(Hash)
              post.each {|key, value|  params[key.downcase] = value }
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
