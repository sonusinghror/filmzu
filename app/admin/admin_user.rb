ActiveAdmin.register AdminUser do
  filter :email

  index do
    column :first_name
    column :last_name
    column :email
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    column :balance do |admin_user|
      number_to_currency admin_user.balance, :unit => "$"
    end
    actions do |admin_user|
      if admin_user.balanced_uri.present?
        link_to "Add Bank Account", add_bank_account_admin_admin_user_path(admin_user), :class => "member_link"
      else
        link_to "Create account on Balanced", create_balanced_account_admin_admin_user_path(admin_user), :class => "member_link"
      end
    end
    column "" do |admin_user|
      if admin_user.bank_accounts.present?
        link_to "Withdraw", withdrawal_form_admin_admin_user_path(admin_user), :class => "member_link"
      end
    end
  end

  show do |admin_user|
    attributes_table do
      columns_to_exclude = ["id", "balance", "balanced_uri", "default_account",
                            "default_backup_account", "default_account_type",
                            "default_backup_account_type"]
      (AdminUser.column_names - columns_to_exclude).each_with_index do |c, index|
        row c.to_sym
        if index == 2
          row :balance do
            "#{ '$' + (admin_user.balance).to_s if admin_user.balance.present? }"
          end
        end
      end
    end
    panel "Bank Accounts" do
      table_for admin_user.bank_accounts do
        column "Bank Account" do |bank_account|
          begin
            Balanced::BankAccount.fetch(bank_account.bank_account_uri).attributes['account_number']
          rescue
            "Error while retrieving"
          end
        end
        column "Bank Name" do |bank_account|
          bank_account.bank_name
        end
        column "" do |bank_account|
          link_to 'Delete', delete_bank_account_admin_admin_user_path(admin_user, :bank_account_id => bank_account.id), data: {confirm: 'Are you sure?'}
        end
      end
    end
  end

  form do |f|
    f.inputs "Admin Details" do
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  member_action :create_balanced_account, :method => :get do
    admin_user = AdminUser.find(params[:id])
    if admin_user.present?
      begin
        if admin_user.balanced_uri.blank?
          customer = Balanced::Customer.new(
            :email => admin_user.email,
            :name => admin_user.name
          )
          customer.save
          admin_user.update_attribute(:balanced_uri, customer.attributes['href'])
          flash[:notice] = 'Balanced account created for admin'
        else
          flash[:notice] = "Balanced account for admin exists"
        end
      rescue
        Rails.logger.info 'Balanced customer entry could not be created for admin'
        flash[:error] = 'Balanced account could not be created for admin'
      end
    else
      flash[:error] = 'No such admin found'
    end
    redirect_to admin_admin_users_path
  end

  member_action :add_bank_account, :method => :get do
    @admin_user = AdminUser.find(params[:id])
  end

  member_action :save_bank_account, :method => :post do
    admin_user = AdminUser.find(params[:id])
    if params[:bank_account].present? && admin_user.present?
      begin
        bank_account = BankAccount.create_balanced_bank_account(params[:bank_account], admin_user)
      rescue Exception => e
        flash[:error] = "Bank account could not be added: #{e.inspect}"
      end
      if bank_account.present?
        flash[:success] = "Bank account addition has been successful."
      else
        flash[:error] = 'Bank account could not be added. Please try again'
      end
    else
      flash[:error] = 'Bank account could not be added'
    end
    redirect_to admin_admin_users_path
  end

  member_action :withdrawal_form, :method => :get do
    @admin_user = AdminUser.find(params[:id])
  end

  member_action :withdraw, :method => :post do
    @admin_user = AdminUser.find(params[:id])
    @bank_account = @admin_user.bank_accounts.first if @admin_user.present?
    if @bank_account.present? && @bank_account.bank_account_uri.present?
      if params[:amount].to_i <= @admin_user.balance
        begin
          bank_account = Balanced::BankAccount.fetch(@bank_account.bank_account_uri)
          response = bank_account.credit(
            :amount => params[:amount].to_i * 100,
            :appears_on_statement_as => "Withdrawal",
            :description => "Withdrawal"
          )
          credits = response.attributes
          withdraw = @admin_user.withdraws.create(
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
            @admin_user.update_column(:balance, @admin_user.balance - params[:amount].to_f)
            flash[:notice] = "The withdrawal of fund was successful"
          end
        rescue Exception => e
          Rails.logger.debug e.inspect
          flash[:error] = "The withdrawal could not be done. Please retry"
        end
      else
        flash[:error] = 'The amount entered is more than your account balance'
      end
    else
      flash[:error] = 'No bank account for this admin found'
    end
    redirect_to admin_admin_users_path
  end

  member_action :delete_bank_account, :method => :get do
    @admin_user = AdminUser.find(params[:id])
    bank_account = @admin_user.bank_accounts.where(:id => params[:bank_account_id]).first
    if bank_account.present? && @admin_user.present?
      begin
        balanced_ba = Balanced::BankAccount.fetch(bank_account.bank_account_uri) if bank_account.present?
        if balanced_ba.present?
          if @admin_user.default_account.present? && @admin_user.default_account == bank_account.id && @admin_user.default_account_type == 'b'
            @admin_user.update_attributes(:default_account => nil, :default_account_type => nil)
          end
          if @admin_user.default_backup_account.present? && @admin_user.default_backup_account == bank_account.id && @admin_user.default_backup_account_type == 'b'
            @admin_user.update_attributes(:default_backup_account => nil, :default_backup_account_type => nil)
          end
          balanced_ba.unstore
          if bank_account.delete
            if @admin_user.default_account.blank? && @admin_user.default_account_type.blank?
              ba = @admin_user.bank_accounts.first
              @admin_user.update_attributes(default_account: ba.id, default_account_type: 'b') if ba.present?
            end
          end
          flash[:success] = "Bank Account has been successfully deleted"
        else
          flash[:error] = "No such bank account found"
        end
      rescue
        flash[:error] = "Bank account could not be deleted. Please try again"
      end
    else
      flash[:error] = 'No such bank account found'
    end
    redirect_to admin_admin_user_path(@admin_user)
  end
end
