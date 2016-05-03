class CreditCard < ActiveRecord::Base
  attr_accessible :card_type, :credit_card_uri, :is_authenticated
  belongs_to :card_accountable, :polymorphic => true

  def self.create_balanced_credit_card card_details_hash, resource
    unless card_details_hash.empty?
      credit_card_response = Balanced::Card.new(
        :cvv => card_details_hash['cvv'],
        :expiration_month => card_details_hash['expiration_month'],
        :expiration_year => card_details_hash['expiration_year'],
        :number => card_details_hash['number'],
        :name => card_details_hash['name']
      ).save

      if credit_card_response

        # associate card to customer
        credit_card_response.associate_to_customer(resource.balanced_uri)

        # STORE BANK ACCOUNT INFORMATION IN DB
        credit_card_details = Balanced::Card.fetch(credit_card_response.attributes['href'])
        if credit_card_details
          credit_card = resource.credit_cards.new
          credit_card.credit_card_uri = credit_card_details.attributes['href']
          credit_card.is_authenticated = true
          credit_card.card_type = credit_card_details.attributes['brand']
          status = false
          status = true if resource.default_account.blank? && resource.default_account_type.blank?
          if credit_card.save
            if status
              resource.update_attributes(default_account: credit_card.id, default_account_type: 'c')
            end
          end
        end
      end
    end
  end

end
