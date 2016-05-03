class Clients::AccountsController < ApplicationController

  before_filter :authenticate_client!

  def index
    @client = current_client
    @bank_accounts = @client.bank_accounts
    @credit_cards = @client.credit_cards
    @default_accounts_array = Array.new
    @bank_accounts.each do |ba|
      @default_accounts_array << [Balanced::BankAccount.fetch(ba.bank_account_uri).attributes['account_number'], "b#{ba.id}"] if ba.verification_status == 'succeeded'
    end
    @credit_cards.each do |cc|
      @default_accounts_array << [Balanced::Card.fetch(cc.credit_card_uri).attributes['number'], "c#{cc.id}"]
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @clients }
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

  def add_fund
    render layout: 'popup'
  end

  def client_deposit_fund
    if params[:amount].present?
      account, msg = current_client.account_to_use
      case msg
        when 'credit_card' then
          credit_card_deposit(account, params[:amount])
        when 'bank_account' then
          bank_account_deposit(account, params[:amount])
        when 'no_default_account' then
          flash[:error] = "Default account could not be found"
        when 'no_default_backup_account' then
          flash[:error] = "Default account and Default backup account could not be found"
        when 'no_default_and_backup_account' then
          flash[:error] = "Please save an account as default account to add fund"
      end
    else
      flash[:error] = "Amount is mandatory"
    end
    redirect_to clients_accounts_url
  end

  def bank_account_deposit(bank_account_id, amount)
    default_account = current_client.bank_accounts.where(id: bank_account_id).first
    if default_account.present?
      begin
        bank_account = Balanced::BankAccount.fetch(default_account.bank_account_uri)
        response = bank_account.debit(
          :amount => amount.to_i * 100,
          :appears_on_statement_as => "Funded",
          :description => "Funded",
          :source_uri => default_account.bank_account_uri
        )
        debits = response.attributes
        deposit_hash = {
          amount: amount.to_i * 100,
          appears_on_statement_as: debits['appears_on_statement_as'],
          balanced_created_at: debits['created_at'],
          currency: debits['currency'],
          description: debits['description'],
          failure_reason: debits['failure_reason'],
          failure_reason_code: debits['failure_reason_code'],
          href: debits['href'],
          balanced_id: debits['id'],
          status: debits['status'],
          transaction_number: debits['transaction_number'],
          balanced_updated_at: debits['updated_at']
        }
        deposit = current_client.deposits.create(deposit_hash)
        if debits['failure_reason_code'].present? || debits['failure_reason'].present?
          flash[:error] = "#{debits['failure_reason']}"
        else
          current_client.update_attribute(:balance, current_client.balance + amount.to_i)
          flash[:success] = "The addition of fund was successful"
        end
      rescue Exception => e
        flash[:error] = "The addition of fund was not successful. Please try again"
      end
    else
      flash[:error] = "No default account found"
    end
  end

  def credit_card_deposit(credit_card_id, amount)
    default_account = current_client.credit_cards.where(id: credit_card_id).first
    if default_account.present?
      begin
        credit_card = Balanced::Card.fetch(default_account.credit_card_uri)
        response = credit_card.debit(
          :amount => amount.to_i * 100,
          :appears_on_statement_as => "Funded",
          :description => "Funded",
          :source_uri => default_account.credit_card_uri
        )
        debits = response.attributes
        deposit_hash = {
          amount: amount.to_i * 100,
          appears_on_statement_as: debits['appears_on_statement_as'],
          balanced_created_at: debits['created_at'],
          currency: debits['currency'],
          description: debits['description'],
          failure_reason: debits['failure_reason'],
          failure_reason_code: debits['failure_reason_code'],
          href: debits['href'],
          balanced_id: debits['id'],
          status: debits['status'],
          transaction_number: debits['transaction_number'],
          balanced_updated_at: debits['updated_at'],
          link_card_hold: debits['links']['card_hold'],
          link_customer: debits['links']['customer'],
          link_dispute: debits['links']['dispute'],
          link_order: debits['order'],
          link_source: debits['source']
        }
        deposit = current_client.deposits.create(deposit_hash)
        if debits['failure_reason_code'].present? || debits['failure_reason'].present?
          flash[:error] = "#{debits['failure_reason']}"
        else
          current_client.update_attribute(:balance, current_client.balance + amount.to_i)
          flash[:success] = "The addition of fund was successful"
        end
      rescue Balanced::Error => e
        ebody = e.body
        if ebody.present? && ebody.is_a?(Hash) && ebody.has_key?('debits')
          debit_hash = ebody['debits'].first
          if debit_hash.present?
            deposit = Deposit.add_deposit(current_client, debit_hash)
            flash[:error] = "Funds could not be added. #{debit_hash['failure_reason']}"
          end
        else
          flash[:error] = "Funds could not be added. Please try again."
        end
      rescue Exception => e
        flash[:error] = "Funds could not be added. Please try again."
      end
    else
      flash[:error] = "No default account found"
    end
  end

  def create_balanced_credit_card
    # AFTER VALIDATION OF CREDIT CARD DETAILS
    # BUSINESS LOGIC TO CREATE CREDIT ON BALANCED
    if params[:credit_card]

      begin
        CreditCard.create_balanced_credit_card(params[:credit_card], current_client)
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

      if params[:featured_prj].present?
        begin
          client_credit_card = Balanced::Card.fetch(current_client.credit_cards.last.credit_card_uri)
          client_credit_card.debit(:amount => 900, :appears_on_statement_as => 'Statement text')
        rescue
          flash[:error] = "The featured project fee payment was not successful"
        end
      end

    end
    redirect_to clients_accounts_path
  end

  def create_balanced_bank_account

    # AFTER VALIDATION OF BANK ACCOUNT DETAILS
    # BUSINESS LOGIC TO CREATE BANK ACCOUNT ON BALANCED

    if params[:bank_account]
      begin
        bank_account = BankAccount.create_balanced_bank_account(params[:bank_account], current_client)
      rescue Exception => e
        flash[:error] = "Bank account could not be added: #{e.inspect}"
      end
      if bank_account.present? && bank_account.bank_account_uri.present? && bank_account.verification_status != 'failed'
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
          flash[:error] = "Bank account could not be added. Please try again"
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
    redirect_to '/clients/accounts'
  end

  def set_default_account
    if params[:default_account].present?
      account_type = params[:default_account][0]
      id = params[:default_account][1..-1]
      if current_client.update_attributes(:default_account => id, :default_account_type => account_type)
        flash[:success] = "Account was successfully saved as default"
      else
        flash[:error] = "The account could not be set as default. Please try again"
      end
    else
      flash[:error] = "Please select an account to make it default"
    end
    redirect_to clients_accounts_url
  end

  def set_default_backup_account
    if params[:default_backup_account].present?
      backup_account_type = params[:default_backup_account][0]
      id = params[:default_backup_account][1..-1]
      if current_client.update_attributes(:default_backup_account => id, :default_backup_account_type => backup_account_type)
        flash[:success] = "Account was successfully saved as backup account"
      else
        flash[:error] = "The account could not be set as backup account. Please try again"
      end
    else
      flash[:error] = "Please select an account to make it backup account"
    end
    redirect_to clients_accounts_url
  end

  def remove_client_credit_card
    if params[:id].present?
      credit_card = CreditCard.where(id: params[:id]).first
      balanced_cc = Balanced::Card.fetch(credit_card.credit_card_uri) if credit_card.present?
      if credit_card.present? && balanced_cc.present?
        if current_client.default_account.present? && current_client.default_account == credit_card.id && current_client.default_account_type == 'c'
          current_client.update_attributes(:default_account => nil, :default_account_type => nil)
        end
        if current_client.default_backup_account.present? && current_client.default_backup_account == credit_card.id && current_client.default_backup_account_type == 'c'
          current_client.update_attributes(:default_backup_account => nil, :default_backup_account_type => nil)
        end
        balanced_cc.unstore
        if credit_card.delete
          if current_client.default_account.blank? && current_client.default_account_type.blank?
            cc = current_client.credit_cards.first
            if cc.present?
              current_client.update_attributes(default_account: cc.id, default_account_type: 'c')
            else
              ba = current_client.bank_accounts.first
              current_client.update_attributes(default_account: ba.id, default_account_type: 'b') if ba.present?
            end
          end
        end
        flash[:success] = "Credit Card has been successfully deleted"
      else
        flash[:error] = "No such Credit Card found"
      end
    else
      flash[:error] = "No Credit Card selected for deletion"
    end
    redirect_to clients_accounts_url
  end

  def remove_client_bank_account
    if params[:id].present?
      bank_account = BankAccount.where(id: params[:id]).first
      begin
        balanced_ba = Balanced::BankAccount.fetch(bank_account.bank_account_uri) if bank_account.present?
        if bank_account.present? && balanced_ba.present?
          if current_client.default_account.present? && current_client.default_account == bank_account.id && current_client.default_account_type == 'b'
            current_client.update_attributes(:default_account => nil, :default_account_type => nil)
          end
          if current_client.default_backup_account.present? && current_client.default_backup_account == bank_account.id && current_client.default_backup_account_type == 'b'
            current_client.update_attributes(:default_backup_account => nil, :default_backup_account_type => nil)
          end
          balanced_ba.unstore
          if bank_account.delete
            if current_client.default_account.blank? && current_client.default_account_type.blank?
              cc = current_client.credit_cards.first
              if cc.present?
                current_client.update_attributes(default_account: cc.id, default_account_type: 'c')
              else
                ba = current_client.bank_accounts.first
                current_client.update_attributes(default_account: ba.id, default_account_type: 'b') if ba.present?
              end
            end
          end
          flash[:success] = "Bank Account has been successfully deleted"
        else
          flash[:error] = "No such Bank Account found"
        end
      rescue
        flash[:error] = "Bank account could not be deleted. Please try again"
      end
    else
      flash[:error] = "No Bank Account selected for deletion"
    end
    redirect_to clients_accounts_url
  end

  def verify_bank_account_popup
    @bank_account = BankAccount.where(id: params[:id]).first
    return redirect_to clients_accounts_url if @bank_account.blank?
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
    redirect_to clients_accounts_url
  end

  def transactions
    @deposits = current_client.deposits.order('created_at DESC').per_page_kaminari(params[:page]).per(25)
  end

  def feature_project
    @project = Project.where(id: params[:id]).first
    if current_client.bank_accounts.present? || current_client.credit_cards.present?
      status, msg = current_client.featured_project_payment(@project)
      if status
        flash[:success] = msg
      else
        flash[:error] = msg
      end
      redirect_to clients_dashboard_url
    else
      flash[:error] = "No bank or credit card accounts found. Please add an account and save as default and try again."
      redirect_to clients_accounts_url
    end
  end

end
