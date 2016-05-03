class ProAccount < ActiveRecord::Base
  attr_accessible :account_type, :payment_at, :accountable_id, :accountable_type
	belongs_to :accountable, :polymorphic => true
	
	def self.renew_pro_accounts
	  Rails.logger.info "#{Time.now}\n"
	  pro_accounts = ProAccount.where("payment_at >= ? AND payment_at <=? AND account_type=? AND accountable_type=?", Time.now - 2.month, Time.now - 1.month, 'pro', 'Filmmaker')
	  if pro_accounts.present?
	    filmmakers = Filmmaker.where("id IN (?)", pro_accounts.collect(&:accountable_id))
	    filmmakers.each do |fm|
	      fm.make_first_pro_account_transaction
	    end
	  end
	end
end