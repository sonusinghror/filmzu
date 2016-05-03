class Filmmakers::AccountsController < ApplicationController

  before_filter :authenticate_filmmaker!

   def index
    @filmmaker = current_filmmaker
    @bank_accounts = @filmmaker.bank_accounts
    @credit_cards = @filmmaker.credit_cards
    @default_accounts = Array.new
    @bank_accounts.each do |ba|
      @default_accounts << [Balanced::BankAccount.fetch(ba.bank_account_uri).attributes['account_number'], "b#{ba.id}"] if ba.verification_status == 'succeeded'
    end
    @credit_cards.each do |cc|
      @default_accounts << [Balanced::Card.fetch(cc.credit_card_uri).attributes['number'], "c#{cc.id}"]
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @filmmakers }
    end
  end

  def add_bank_account
    @bank_account = BankAccount.new
    render :layout => 'popup'
  end

  def add_credit_card
    @bank_account = CreditCard.new
    render :layout => 'popup'
  end

  def create_balanced_credit_card
    # AFTER VALIDATION OF CREDIT CARD DETAILS
    # BUSINESS LOGIC TO CREATE CREDIT ON BALANCED
    if params[:credit_card]
      begin
        CreditCard.create_balanced_credit_card(params[:credit_card], current_filmmaker)
      rescue Balanced::Error => balanced_error
        be_body = balanced_error.body
        if be_body.present? && be_body.is_a?(Hash) && be_body.has_key?('errors')
          errors = be_body['errors'].first
          if errors.present? && errors.is_a?(Hash)
            flash[:error] = "Credit card could not added: #{errors['additional']}"
          else
            flash[:error] = "Credit card could not be added. Please check the details and try again."
          end
        else
          flash[:error] = "Credit card could not be added. Please check the details and try again."
        end
      rescue Exception => e
        flash[:error] = "Credit card could not be added"
      end
    end
    redirect_to filmmakers_accounts_url
  end

  def create_balanced_bank_account

    # AFTER VALIDATION OF BANK ACCOUNT DETAILS
    # BUSINESS LOGIC TO CREATE BANK ACCOUNT ON BALANCED

    if params[:bank_account]
      begin
        bank_account = BankAccount.create_balanced_bank_account(params[:bank_account], current_filmmaker)
      rescue Exception => e
        flash[:error] = 'Bank account could not be added'
      end
      if bank_account.present? && bank_account.bank_account_uri.present?
        begin
          bav = Balanced::BankAccount.fetch(bank_account.bank_account_uri)
          verification = bav.verify
          v = verification.attributes
          if v.present?
            bank_account_verification = bank_account.bank_account_verifications.new(
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
            bank_account_verification.save!
            bank_account.update_column(:verification_status, v['verification_status'])
            if v['verification_status'].present? && v['verification_status'] == 'failed'
              flash[:error] = 'Bank account verification failed'
            else
              flash[:success] = "Bank account added successfully!"
            end
          end
        rescue
          flash[:error] = "Bank account could not be added"
        end
      else
        if bank_account.present?
          if bank_account.verification_status == 'failed'
            flash[:error] = 'Bank account verification failed'
          else
            flash[:error] = 'Bank verification request could not be sent'
          end
        else
          flash[:error] = 'Bank account could not be added. Please try again'
        end
      end
    end

    redirect_to filmmakers_accounts_url
  end

  def set_default_account
    if params[:default_account].present?
      account_type = params[:default_account][0]
      id = params[:default_account][1..-1]
      if current_filmmaker.update_attributes(:default_account => id, :default_account_type => account_type)
        flash[:success] = "Account was successfully saved as default"
      else
        flash[:error] = "The account could not be set as default. Please try again"
      end
    else
      flash[:error] = "Please select an account to make it default"
    end
    redirect_to filmmakers_accounts_url
  end

  def set_default_backup_account
    if params[:default_backup_account].present?
      backup_account_type = params[:default_backup_account][0]
      id = params[:default_backup_account][1..-1]
      if current_filmmaker.update_attributes(:default_backup_account => id, :default_backup_account_type => backup_account_type)
        flash[:success] = "Account was successfully saved as backup account"
      else
        flash[:error] = "The account could not be set as backup account. Please try again"
      end
    else
      flash[:error] = "Please select an account to make it backup account"
    end
    redirect_to filmmakers_accounts_url
  end

  def remove_filmmaker_credit_card
    if params[:id].present?
      credit_card = CreditCard.where(id: params[:id]).first
      balanced_cc = Balanced::Card.fetch(credit_card.credit_card_uri) if credit_card.present?
      if credit_card.present? && balanced_cc.present?
        if current_filmmaker.default_account.present? && current_filmmaker.default_account == credit_card.id && current_filmmaker.default_account_type == 'c'
          current_filmmaker.update_attributes(:default_account => nil, :default_account_type => nil)
        end
        if current_filmmaker.default_backup_account.present? && current_filmmaker.default_backup_account == credit_card.id && current_filmmaker.default_backup_account_type == 'c'
          current_client.update_attributes(:default_backup_account => nil, :default_backup_account_type => nil)
        end
        balanced_cc.unstore
        credit_card.delete
        flash[:success] = "Credit Card has been successfully deleted"
      else
        flash[:error] = "No such Credit Card found"
      end
    else
      flash[:error] = "No Credit Card selected for deletion"
    end
    redirect_to filmmakers_accounts_url
  end

  def remove_filmmaker_bank_account
    if params[:id].present?
      bank_account = BankAccount.where(id: params[:id]).first
      balanced_ba = Balanced::BankAccount.fetch(bank_account.bank_account_uri) if bank_account.present?
      if bank_account.present? && balanced_ba.present?
        if current_filmmaker.default_account.present? && current_filmmaker.default_account == bank_account.id && current_filmmaker.default_account_type == 'b'
          current_filmmaker.update_attributes(:default_account => nil, :default_account_type => nil)
        end
        if current_filmmaker.default_backup_account.present? && current_filmmaker.default_backup_account == bank_account.id && current_filmmaker.default_backup_account_type == 'b'
           current_filmmaker.update_attributes(:default_backup_account => nil, :default_backup_account_type => nil)
        end
        balanced_ba.unstore
        bank_account.delete
        flash[:success] = "Bank Account has been successfully deleted"
      else
        flash[:error] = "No such Bank Account found"
      end
    else
      flash[:error] = "No Bank Account selected for deletion"
    end
    redirect_to filmmakers_accounts_url
  end

  def withdraw_fund_popup
    render layout: 'popup'
  end

  def withdraw_fund
    if params[:amount].present? && params[:amount].to_f <= current_filmmaker.balance
      account, msg = current_filmmaker.account_to_use
      case msg
        when 'credit_card' then
          credit_card_withdraw(account, params[:amount].to_i)
        when 'bank_account' then
          balance_account_withdraw(account, params[:amount].to_i)
        when 'no_default_account' then
          flash[:error] = "Default account could not be found"
        when 'no_default_backup_account' then
          flash[:error] = "Default backup account could not be found"
        when 'no_default_and_backup_account' then
          flash[:error] = "Please select an account as default account to withdraw"
      end
    else
      flash[:error] = (params[:amount].present?) ? 'The amount entered is more than your account balance' : 'Please enter amount to withdraw'
    end
    redirect_to filmmakers_accounts_url
  end

  def balance_account_withdraw(bank_account_id, amount)
    default_bank_account = current_filmmaker.bank_accounts.where(id: bank_account_id).first
    if default_bank_account.present?
      begin
        bank_account = Balanced::BankAccount.fetch(default_bank_account.bank_account_uri)
        response = bank_account.credit(
          :amount => params[:amount].to_i * 100,
          :appears_on_statement_as => "Withdrawal",
          :description => "Withdrawal"
        )
        credits = response.attributes
        withdraw = current_filmmaker.withdraws.create(
          amount: credits['amount'],
          appears_on_statement_as: credits['appears_on_statement_as'],
          balanced_created_at: credits['created_at'],
          currency: credits['currency'],
          description: credits['description'],
          failure_reason: credits['failure_reason'],
          failure_reason_code: credits['failure_reason_code'],
          href: credits['href'],
          balanced_id: credits['id'],
          status: credits['status'],
          transaction_number: credits['transaction_number'],
          balanced_updated_at: credits['updated_at'],
          link_customer: "#{credits['links']['customer'] rescue nil}",
          link_destination: "#{credits['links']['destination'] rescue nil}"
        )
        if credits['failure_reason_code'].present? || credits['failure_reason'].present?
          flash[:error] = "#{response['failure_reason']}"
        else
          current_filmmaker.update_column(:balance, current_filmmaker.balance - params[:amount].to_f)
          flash[:success] = "The withdrawal of fund was successful"
        end
      rescue Exception => e
        Rails.logger.debug e.inspect
        flash[:error] = "The withdrawal could not be done. Please retry"
      end
    else
      flash[:error] = "Please add an account and retry"
    end
  end

  def credit_card_withdraw(credit_card_id, amount)
    if amount.present? && amount.to_f < 2500
      default_account = current_filmmaker.credit_cards.where(id: credit_card_id).first
      if default_account.present?
        begin
          credit_card = Balanced::Card.fetch(default_account.credit_card_uri)
          response = credit_card.credit(
            :amount => params[:amount].to_i * 100,
            :appears_on_statement_as => "Withdrawal",
            :description => "Withdrawal"
          )
          credits = response.attributes
          withdraw = current_filmmaker.withdraws.create(
            amount: credits['amount'],
            appears_on_statement_as: credits['appears_on_statement_as'],
            balanced_created_at: credits['created_at'],
            currency: credits['currency'],
            description: credits['description'],
            failure_reason: credits['failure_reason'],
            failure_reason_code: credits['failure_reason_code'],
            href: credits['href'],
            balanced_id: credits['id'],
            status: credits['status'],
            transaction_number: credits['transaction_number'],
            balanced_updated_at: credits['updated_at'],
            link_customer: "#{credits['links']['customer'] rescue nil}",
            link_destination: "#{credits['links']['destination'] rescue nil}"
          )
          if credits['failure_reason_code'].present? || credits['failure_reason'].present?
            flash[:error] = "#{response['failure_reason']}"
          else
            current_filmmaker.update_column(:balance, current_filmmaker.balance - params[:amount].to_f)
            flash[:success] = "The withdrawal of fund was successful"
          end
        rescue
          flash[:error] = "The withdrawal of fund could not be done. Please retry"
        end
      else
        flash[:error] = "Please add an account and retry"
      end
    else
      flash[:error] = "You can only credit a maximum of $2500 in your credit card"
    end
  end

  def transactions
    @withdraws = current_filmmaker.withdraws.order('created_at DESC').per_page_kaminari(params[:page]).per(25)
  end

  def verify_bank_account_popup
    @bank_account = BankAccount.where(id: params[:id]).first
    return redirect_to filmmakers_accounts_url if @bank_account.blank?
    render layout: 'popup'
  end

  def verify_bank_account
    if params[:amount_one].blank? || params[:amount_two].blank?
      flash[:error] = "Amount fields are mandatory"
    else
      @bank_account = BankAccount.where(id: params[:id]).first
      if @bank_account.present?
        bank_account_verification = @bank_account.bank_account_verifications.last
        bank_account_verification.confirm_bank_account(params) if bank_account_verification.present?
        if @bank_account.verification_status == 'succeeded'
          flash[:success] = "Your bank account verification was successful"
        else
          flash[:notice] = "Your bank account verification is in process"
        end
      else
        flash[:error] = "No bank account found the details provided. Please retry"
      end
    end
    redirect_to filmmakers_accounts_url
  end
end
