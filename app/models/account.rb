class Account < ActiveRecord::Base
  belongs_to :user
  belongs_to :client
  belongs_to :filmmaker
  belongs_to :meta, polymorphic: true
  
  attr_accessible :account_id, :backup_payment, :credit_card, :default_account
end
