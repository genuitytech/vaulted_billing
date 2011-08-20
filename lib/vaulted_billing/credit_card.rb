require 'iso3166'

module VaultedBilling
  ##
  # Intermediary class used to translate your local credit card information
  # into data which VaultedBilling can recognize and use.
  #
  # Generally - and this is gateway specific - the only data which is
  # actually required is the card number and expiration date (expires_on).
  # Most of the other data is optional and may or may not be stored by
  # your gateway.
  #
  # Note: The vault_id is the unique identifier generated by your gateway
  # when you initially store the customer information.  This should be
  # kept and stored locally, related to your local credit card information.
  # If you generate a CreditCard object with a vault_id, it is assumed that
  # the card is already stored on the gateway and is not new information.
  #
  class CreditCard
    class Country < String
      def to_iso_3166
        country.number.to_i if country.data
      end
      
      def to_ipcommerce_id
        country.data ? (VaultedBilling::Gateways::Ipcommerce::Countries.index(country.alpha3) || 0) : 0
      end

      private
      
      def country
        ISO3166::Country.new(self)
      end
    end
    
    attr_accessor :card_number # The customer's credit card number
    attr_reader :country # The country of the credit card address.
    attr_accessor :currency # The currency used by the credit card.
    attr_accessor :cvv_number # The verification number (CVV2) on the card.
    attr_accessor :expires_on # The date on which the credit card expires.
    attr_accessor :first_name # The first name of the cardholder.
    attr_accessor :last_name # The last name of the cardholder.
    attr_accessor :locality # The "city" of the address on the card.
    attr_accessor :phone # A phone number for the cardholder.
    attr_accessor :postal_code # The postal code (zipcode) for the card.
    attr_accessor :region # The "state" of the address on the card.
    attr_accessor :street_address # The house number and street name of the card address.
    attr_accessor :vault_id # The unique, gateway-generated identifier for this credit card.

    ##
    # You may define any of the CreditCard attributes by passing a hash
    # with the attribute name as the key:
    #
    #     CreditCard.new(:card_number => '4111....')
    #
    def initialize(attributes = {})
      attributes = HashWithIndifferentAccess.new(attributes)
      attributes.each_pair do |key, value|
        send("#{key}=", value) if respond_to?("#{key}=")
      end
    end
    
    def ==(o)
      self.attributes == o.attributes
    end

    def attributes
      {
        :vault_id => vault_id,
        :currency => currency,
        :card_number => card_number,
        :cvv_number => cvv_number,
        :expires_on => expires_on,
        :first_name => first_name,
        :last_name => last_name,
        :street_address => street_address,
        :locality => locality,
        :region => region,
        :postal_code => postal_code,
        :country => country,
        :phone => phone
      }
    end

    def country=(input)
      @country = Country.new(input) if input
    end

    def name_on_card
      [first_name, last_name].compact.join(" ")
    end

    def to_vaulted_billing; self; end
  end
end
