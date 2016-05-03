class BankAccount < ActiveRecord::Base
  attr_accessible :bank_account_uri, :bank_name, :verification_status
  belongs_to :bank_accountable, :polymorphic => true
  has_many :bank_account_verifications

  def self.create_balanced_bank_account account_details_hash, resource
    unless account_details_hash.empty?
      account_type = 'checking'
      account_type = 'savings' if account_details_hash['account_type'].eql?('saving')

      bank_account_response = Balanced::BankAccount.new(
        :account_number => account_details_hash['account_number'],
        :account_type => account_type,
        :name => account_details_hash['name'],
        :routing_number => account_details_hash['routing_number']
      ).save

      if bank_account_response

        # associate bank account to customer
        bank_account_response.associate_to_customer(resource.balanced_uri)

        # STORE BANK ACCOUNT INFORMATION IN DB
        balanced_bank_account_details = Balanced::BankAccount.fetch(bank_account_response.attributes['href'])
        if balanced_bank_account_details
          bank_account = resource.bank_accounts.new
          bank_account.bank_account_uri = balanced_bank_account_details.attributes['href']
          bank_account.bank_name = balanced_bank_account_details.attributes['bank_name']
          status = false
          status = true if resource.default_account.blank? && resource.default_account_type.blank?
          if bank_account.save
            if status
              resource.update_attributes(default_account: bank_account.id, default_account_type: 'b')
            end
          end
          return bank_account
        end
      end
    end
  end

end
