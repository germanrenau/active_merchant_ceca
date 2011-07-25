# encoding: utf-8
require File.expand_path('../../../test_helper', __FILE__)

class CecaModuleTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def test_currency_code
    assert_equal '978', Ceca.currency_code('EUR')
  end
  def test_currency_from_code
    assert_equal 'EUR', Ceca.currency_from_code('978')
  end

  def test_language_code
    assert_equal Ceca.language_code('es'), '01'
    assert_equal Ceca.language_code('CA'), '02'
    assert_equal Ceca.language_code(:pt), '09'
  end
  def test_language_from_code
    assert_equal :ca, Ceca.language_from_code('02')
  end

#  def test_transaction_code
#    assert_equal '2', Ceca.transaction_code(:confirmation)
#  end
#  def test_transaction_from_code
#    assert_equal :confirmation, Ceca.transaction_from_code(2)
#  end

  def test_response_message_from_code
    assert_equal nil, Ceca.response_message_from_code(23)
    assert_equal nil, Ceca.response_message_from_code('23')
    assert_equal "Operación no realizable", Ceca.response_message_from_code(190)
  end

end 
