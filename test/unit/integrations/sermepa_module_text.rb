require File.expand_path('../../../test_helper', __FILE__)

class CecaModuleTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations
  
  def test_notification_method
    assert_instance_of Ceca::Notification, Ceca.notification('name=cody')
  end

  def test_currency_code
    assert_equal '978', Ceca.currency_code('EUR')
  end
  def test_currency_from_code
    assert_equal 'EUR', Ceca.currency_from_code('978')
  end

  def test_language_code
    assert_equal Ceca.language_code('es'), '001'
    assert_equal Ceca.language_code('CA'), '003'
    assert_equal Ceca.language_code(:pt), '009'
  end
  def test_language_from_code
    assert_equal :ca, Ceca.language_from_code('003')
  end

  def test_transaction_code
    assert_equal '2', Ceca.transaction_code(:confirmation)
  end
  def test_transaction_from_code
    assert_equal :confirmation, Ceca.transaction_from_code(2)
  end

  def test_response_code_message
    assert_equal nil, Ceca.response_code_message(23)
    assert_equal nil, Ceca.response_code_message('23')
    assert_equal "Tarjeta caducada", Ceca.response_code_message(101)
  end

end 
