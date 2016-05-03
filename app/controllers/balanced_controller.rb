class BalancedController < ApplicationController
require 'balanced'
  #Balanced.configure('ak-test-1TH4dhO3BZIaOhzziJFpUTQi4zVZgwn6u')

  def create_balanced_account
      current_user.balanced_account_uri = Balanced::Marketplace.my_marketplace.create_customer(:email => current_user.email, :type => 'person').uri
      current_user.save
      redirect_to root_url
    end

  def bankaccount_form
     #render the form to collect bank account info. 
  end

  def store_bank_account
      balanced_account = Balanced::Customer.find(current_user.balanced_account_uri)
      balanced_account.add_bank_account(params[:balancedBankAccountURI]) 
      redirect_to root_url
  end

  


    def process_payment
      balanced_account = Balanced::Account.find(current_user.balanced_account_uri)
      account.debit(
        :amount => 1000, # or params[:amount]
        :description => "Balanced Payments transaction",
        :appears_on_statement_as => "Balanced Payments")
      # add a redirect to the desired path
        redirect_to root_url
    end

end
