class BankAccountVerification < ActiveRecord::Base
  belongs_to :bank_account

  attr_accessible :attempts, :attempts_remaining, :balanced_created_at,
                  :deposit_status, :href, :balanced_id, :link_bank_account,
                  :balanced_updated_at, :verification_status

  def confirm_bank_account(params)
    begin
      bank_account = self.bank_account
      verification = Balanced::BankAccountVerification.fetch(self.href)
      response = verification.confirm(
        amount_1 = params[:amount_one],
        amount_2 = params[:amount_two]
      )
      v = response.attributes
      if v.present?
        response_bav = bank_account.bank_account_verifications.new(
          attempts: v['attempts'],
          attempts_remaining: v['attempts_remaining'],
          balanced_created_at: v['created_at'],
          deposit_status: v['deposit_status'],
          href: v['href'],
          balanced_id: v['id'],
          link_bank_account: "#{v['links']['bank_account']}",
          balanced_updated_at: v['updated_at'],
          verification_status: v['verification_status']
        )
        response_bav.save!
        bank_account.update_column(:verification_status, v['verification_status'])
      end
    rescue Exception => e
      Rails.logger.debug "\n Bank account verification could not be done \n"
    end
  end
end
