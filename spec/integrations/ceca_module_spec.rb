# encoding: utf-8
require 'spec_helper'


include ActiveMerchant::Billing::Integrations

describe ActiveMerchant::Billing::Integrations::Ceca do
  before do
    Ceca.test_encryption_key = "12345678" 
    Ceca.production_encryption_key = "87654321" 

    Ceca.service_test_url = "http://test.service.spec.com"
    Ceca.service_production_url = "http://production.service.spec.com"

    Ceca.operations_test_url = "http://test.operations.spec.com" 
    Ceca.operations_production_url = "http://production.operations.spec.com"
  end

  context "when integration_mode == :test" do 
    before { ActiveMerchant::Billing::Base.integration_mode = :test }

    it "'encryption_key' should return test's encription key" do
      Ceca.encryption_key.should == "12345678"
    end
    it "'service_url' should return test's service url" do
      Ceca.service_url.should == "http://test.service.spec.com"
    end
    it "'operations_url' should return test's operations url" do
      Ceca.operations_url.should == "http://test.operations.spec.com"      
    end
  end

  context "when integration_mode == :production" do 
    before { ActiveMerchant::Billing::Base.integration_mode = :production }

    it "'encryption_key' should return production's encription key" do
      Ceca.encryption_key.should == "87654321"
    end
    it "'service_url' should return production's service url" do
      Ceca.service_url.should == "http://production.service.spec.com"
    end
    it "'operations_url' should return production's operations url" do
      Ceca.operations_url.should == "http://production.operations.spec.com"
    end
  end

  describe ".currency_code" do
    it "should return the correct currency code" do
      Ceca.currency_code('EUR').should == "978"
    end
  end

  describe ".currency_from_code" do
    it "should return the correct currency name" do
      Ceca.currency_from_code('978').should == 'EUR' 
    end
  end

  describe ".language_code" do
    it "should return the correct language code" do
      Ceca.language_code('es').should == '01'
      Ceca.language_code('CA').should == '02'
      Ceca.language_code(:pt).should == '09'
    end
  end

  describe ".language_from_code" do
    it "should return the correct language name" do
      Ceca.language_from_code('02').should == :ca
    end 
  end

  describe ".response_message_from_code" do
    it "should return the correct response message" do
      Ceca.response_message_from_code(0).should == "OPERACIÓN AUTORIZADA"
      Ceca.response_message_from_code("01").should == "COMUNICACION ON-LINE INCORRECTA"
    end 
  end
end 
