class Clients::ProjectsController < ApplicationController

  before_filter :authenticate_client!

  def index
    @client = current_client
    @proposals = []
    if (params.has_key?(:proposals_search) && params[:proposals_search] != "Search Proposals") && (params[:project_id])
      if params[:project_id]
        @project = Project.where("id = ? AND user_id = ?",url_decode(params[:project_id]),current_client.id).first
        project_proposals = ProjectProposal.where("cover_letter = ? AND project_id = ?","%#{params[:proposals_search]}%",@project.id)
        filmmakers_ids = Filmmaker.where("name = ? OR location = ? OR skills = ?",params[:proposals_search],params[:proposals_search],params[:proposals_search]).collect(&:id)
        @proposals = @project.project_proposal_details(@project.project_proposals.where("(filmmaker_id IN (?) AND project_id = ?) AND (is_delete = ?)",filmmakers_ids,@project.id,false) + project_proposals)
      end
    elsif params[:project_id]
      @project = Project.where("id = ? AND user_id = ?",url_decode(params[:project_id]),current_client.id).first
      unless @project.blank?
        @proposals = @project.project_proposal_details
        days_ans = @project.project_questions.find_by_question_text("Proposals due by").answer_text.split(" ").first rescue 0
        end_date = @project.created_at.utc + days_ans.to_i.days
        rem_days = (((end_date - Time.now) / 3600) / 24).to_i
        @proposals_due_by = rem_days.to_s+'d'
      end
    else
      @project = @client.projects.last
      @proposals = @project.project_proposal_details
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @clients }
      format.js
    end
  end

  def create_project
    render :layout => 'popup'
  end

  def create
    Project.create_new_project params, request.remote_ip, current_client
    flash[:success] = "Your project has been created"
    redirect_to :back
  end

  def hire_proposal
    proposal = ProjectProposal.find(params[:proposal_id])
    ProjectHire.create(:filmmaker_id => proposal.filmmaker_id, :client_id => current_client.id, :proposal_id => proposal.id) if ProjectHire.where(:filmmaker_id=>proposal.filmmaker_id, :client_id=>current_client.id, :proposal_id=>proposal.id).empty?
    redirect_to "/clients/dashboard"
  end

  def remove_proposal
    proposal = ProjectProposal.find(url_decode(params[:proposal_id]))
    proposal.update_attributes(:is_delete => true)
    redirect_to "/clients/dashboard"
  end

  def accept_project_proposal
    proposal = ProjectProposal.find(params[:proposal_id])
    if proposal.update_attributes(:is_approved => true, :is_declined => false)
      ProjectHire.hire_filmmaker proposal, "client"
    end
    @conversation = Message.where("conversation_id = ?",proposal.conversation_id).first
    respond_to do |format|
     format.js
     format.html { redirect_to :back }
    end
  end

  def decline_project_proposal
    proposal = ProjectProposal.find(params[:proposal_id])
    if proposal.update_attributes(:is_declined => true, :is_approved => false)
      filmmaker = Filmmaker.where(id: proposal.filmmaker_id).first
      if current_client.present? && filmmaker.present?
        current_client.send_message(filmmaker, "Your proposal has been rejected for #{proposal.project.title rescue nil}", 'Your proposal has been rejected')
      end
      @flash = "Your proposal has been rejected!"
    else
      @flash = "Proposal could not be declined. Please try again"
    end
    @conversation = Message.where("conversation_id = ?",proposal.conversation_id).first
    respond_to do |format|
     format.js
     format.html { redirect_to :back, alert: @flash  }
    end
  end

  def edit_proposal
    @project_proposal = ProjectProposal.find(params[:proposal_id])
    @project = @project_proposal.project
	  @client_details = @project.client_details
	  @proposal_details = @project.new_proposal_details @project_proposal.filmmaker_id
	  @proposal = @project.project_proposals.build
	  @filmmaker = Filmmaker.find(@project_proposal.filmmaker_id)
    render :layout => 'dialog'
  end

  def release_payment
    @project_proposal = ProjectProposal.find(params[:proposal_id])
    @filmmaker = @project_proposal.filmmaker
    if @project_proposal.is_modified && !@project_proposal.proposal_revisions.blank?
      last_revision = @project_proposal.proposal_revisions.last
      @updated_milestones = last_revision.updated_project_proposal_milestones.order('created_at ASC')
    else
      @milestones = @project_proposal.project_proposal_milestones.order('created_at ASC')
    end
    render :layout => 'popup'
  end

  def release_direct_hire_payment
    @direct_hire_proposal = DirectHireProposal.find(params[:id])
    @filmmaker = @direct_hire_proposal.filmmaker
    @milestones = @direct_hire_proposal.direct_hire_proposal_milestones.order('created_at ASC')
    render :layout => 'popup'
  end

  def escrow_milestone_funds
    milestone = ProjectProposalMilestone.find(params[:milestone_id])
    @proposal = milestone.project_proposal
    project = @proposal.project
    @filmmaker = @proposal.filmmaker
    if milestone
      if params[:action_type].present?
        #Release fund for milestone
        admin_user = AdminUser.first
        if milestone.fund_escrowed
          admin_amount = milestone.amount.to_i / 10
          admin_user.update_attribute(:balance, admin_amount)
          filmmaker_amount = milestone.amount.to_i - admin_amount.to_i
          account, msg = @filmmaker.account_to_use
          case msg
            when 'credit_card' then
              credit_card_withdraw(account, filmmaker_amount.to_i, milestone, @filmmaker)
            when 'bank_account' then
              balance_account_withdraw(account, filmmaker_amount.to_i, milestone, @filmmaker)
            when 'no_default_account', 'no_default_backup_account', 'no_default_and_backup_account' then
              flash[:success] = "Payment has been released"
              @filmmaker.update_attribute(:balance, @filmmaker.balance + filmmaker_amount.to_i)
              milestone.update_attributes(:payment_released => true, :pay_amount => milestone.amount.to_i)
          end
        else
          flash[:error] = "Please fund the milestone in order to release funds"
        end
      else
        #Fund milestone
        amount_after_balance = 0
        charge_client = false

        if current_client.balance.to_i >= milestone.amount.to_i
          amount_after_balance = current_client.balance.to_i - milestone.amount.to_i
          current_client.update_attribute(:balance, amount_after_balance)
          if !project.is_filmmaker_working_in_project?
            ProjectHire.create(:filmmaker_id => @filmmaker.id, :client_id => current_client.id, :proposal_id => @proposal.id)
          end
          milestone.update_attributes(:fund_escrowed => true, :escrowed_at => Time.now)
          flash[:success] = "Funding of milestone successful"
        else
          amount_to_charge = milestone.amount.to_i - current_client.balance.to_i
          account, msg = current_client.account_to_use
          case msg
            when 'credit_card' then
              credit_card_deposit(account, amount_to_charge.to_i, project, @filmmaker, @proposal, milestone)
            when 'bank_account' then
              bank_account_deposit(account, amount_to_charge.to_i, project, @filmmaker, @proposal, milestone)
            when 'no_default_account' then
              flash[:error] = "Default account could not be found"
              return redirect_to clients_accounts_path
            when 'no_default_backup_account' then
              flash[:error] = "Default account and Default backup account could not be found"
              return redirect_to clients_accounts_path
            when 'no_default_and_backup_account' then
              flash[:error] = "Please save an account as default account to add fund"
              return redirect_to clients_accounts_path
          end
        end #Charge from balance or account conditional end
      end #Fund or release milestone end
    end #Milestone presence check end
   redirect_to :back
  end

  def download_attachment
    project_proposal = ProjectProposal.where("id = ?",params[:proposal_id]).first
    filmmaker = project_proposal.filmmaker
    unless project_proposal.proposal_resumes.blank?
      file_name = project_proposal.project.title + "_" + filmmaker.name + "_attachments.zip"
      t = Tempfile.new("my-temp-filename-#{Time.now}")
      Zip::ZipOutputStream.open(t.path) do |z|
        project_proposal.proposal_resumes.each do |prores|
          attachment = prores.attachment
          title = attachment.url.split("/")[5]
          z.put_next_entry(title)
          z.print IO.read(attachment.path)
        end
      end
      send_file t.path, :type => 'application/zip', :disposition => 'attachment', :filename => file_name
      t.close
    end
  end

  def hire_filmmaker
    @proposal = ProjectProposal.find(url_decode(params[:proposal_id]))
    if @proposal.update_attributes(:is_approved => true, :is_declined => false)
      ProjectHire.hire_filmmaker @proposal, "client"
    end
    render :layout => 'popup'
  end

  def bank_account_deposit(bank_account_id, amount, project, filmmaker, proposal, milestone, direct_hire=false)
    default_account = current_client.bank_accounts.where(id: bank_account_id).first
    if default_account.present?
      begin
        bank_account = Balanced::BankAccount.fetch(default_account.bank_account_uri)
        response = bank_account.debit(
          :amount => amount.to_i * 100,
          :appears_on_statement_as => "Escrow Fund",
          :description => "Escrow Fund",
          :source_uri => default_account.bank_account_uri
        )
        debits = response.attributes
        deposit = current_client.deposits.create(
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
        )
        if debits['failure_reason_code'].present? || debits['failure_reason'].present?
          flash[:error] = "#{debits['failure_reason']}"
        else
          if direct_hire
            if !project.is_filmmaker_working_in_direct_hire_project?
              ProjectDirectHire.create(:filmmaker_id => filmmaker.id, :client_id => current_client.id, :direct_hire_proposal_id => proposal.id)
            end
          else
            if !project.is_filmmaker_working_in_project?
              proposal_revision_id = milestone.proposal_revision.id if milestone.proposal_revision.present?
              if proposal_revision_id.present?
                ProjectHire.create(:filmmaker_id => filmmaker.id, :client_id => current_client.id, :proposal_id => proposal.id, :proposal_revision_id => proposal_revision_id)
              else
                ProjectHire.create(:filmmaker_id => filmmaker.id, :client_id => current_client.id, :proposal_id => proposal.id)
              end
            end
          end
          milestone.update_attributes(:fund_escrowed => true, :escrowed_at => Time.now)
          current_client.update_attribute(:balance, 0.0)
          flash[:success] = "The milestone was successfully funded."
        end
      rescue Exception => e
        flash[:error] = "Milestone could not be funded"
      end
    else
      flash[:error] = "No default account found"
    end
  end

  def credit_card_deposit(credit_card_id, amount, project, filmmaker, proposal, milestone, direct_hire=false)
    default_account = current_client.credit_cards.where(id: credit_card_id).first
    if default_account.present?
      begin
        credit_card = Balanced::Card.fetch(default_account.credit_card_uri)
        response = credit_card.debit(
          :amount => amount.to_i * 100,
          :appears_on_statement_as => "Escrow Fund",
          :description => "Escrow Fund",
          :source_uri => default_account.credit_card_uri
        )
        debits = response.attributes
        deposit = current_client.deposits.create(
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
        )
        if debits['failure_reason_code'].present? || debits['failure_reason'].present?
          flash[:error] = "#{debits['failure_reason']}"
        else
          if direct_hire
            if !project.is_filmmaker_working_in_direct_hire_project?
              ProjectDirectHire.create(:filmmaker_id => filmmaker.id, :client_id => current_client.id, :direct_hire_proposal_id => proposal.id)
            end
          else
            if !project.is_filmmaker_working_in_project?
              proposal_revision_id = milestone.proposal_revision.id unless milestone.class == ProjectProposalMilestone
              if proposal_revision_id.present?
                ProjectHire.create(:filmmaker_id => filmmaker.id, :client_id => current_client.id, :proposal_id => proposal.id, :proposal_revision_id => proposal_revision_id)
              else
                ProjectHire.create(:filmmaker_id => filmmaker.id, :client_id => current_client.id, :proposal_id => proposal.id)
              end
            end
          end
          milestone.update_attributes(:fund_escrowed => true, :escrowed_at => Time.now)
          current_client.update_attribute(:balance, 0.0)
          flash[:success] = "The milestone was successfully funded"
        end
      rescue Exception => e
        flash[:error] = "The milestone could not be funded"
      end
    else
      flash[:error] = "No default backup account found"
    end
  end

  def balance_account_withdraw(bank_account_id, amount, milestone, filmmaker)
    default_bank_account = filmmaker.bank_accounts.where(id: bank_account_id).first
    if default_bank_account.present?
      begin
        bank_account = Balanced::BankAccount.fetch(default_bank_account.bank_account_uri)
        response = bank_account.credit(
          :amount => amount * 100,
          :appears_on_statement_as => 'Payment',
          :description => 'Payment Released'
        )
        credits = response.attributes
        withdraw = filmmaker.withdraws.create(
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
          flash[:success] = 'The withdrawal of fund was successful'
          filmmaker.update_attribute(:balance, filmmaker.balance + amount)
        else
          flash[:success] = 'The withdrawal of fund was successful'
        end
        milestone.update_attributes(:payment_released => true, :pay_amount => milestone.amount.to_i)
      rescue Exception => e
        flash[:success] = 'The withdrawal of fund was successful'
        filmmaker.update_attribute(:balance, filmmaker.balance + amount)
        milestone.update_attributes(:payment_released => true, :pay_amount => milestone.amount.to_i)
      end
    else
      flash[:success] = 'The withdrawal of fund was successful'
      filmmaker.update_attribute(:balance, filmmaker.balance + amount)
      milestone.update_attributes(:payment_released => true, :pay_amount => milestone.amount.to_i)
    end
  end

  def credit_card_withdraw(credit_card_id, amount, milestone, filmmaker)
    if amount.present? && amount.to_i < 2500
      default_account = filmmaker.credit_cards.where(id: credit_card_id).first
      if default_account.present?
        begin
          credit_card = Balanced::Card.fetch(default_account.credit_card_uri)
          response = credit_card.credit(
            :amount => amount * 100,
            :appears_on_statement_as => "Payment",
            :description => "Payment Released",
            :destination => default_account.credit_card_uri
          )
          credits = response.attributes
          withdraw = filmmaker.withdraws.create(
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
            flash[:success] = 'The withdrawal of fund was successful'
            filmmaker.update_attribute(:balance, filmmaker.balance + milestone.amount.to_i)
          else
            flash[:success] = 'The withdrawal of fund was successful'
          end
          milestone.update_attributes(:payment_released => true, :pay_amount => milestone.amount.to_i)
        rescue Exception => e
          flash[:success] = 'The withdrawal of fund was successful'
          filmmaker.update_attribute(:balance, filmmaker.balance + milestone.amount.to_i)
          milestone.update_attributes(:payment_released => true, :pay_amount => milestone.amount.to_i)
        end
      else
        filmmaker.update_attribute(:balance, filmmaker.balance + milestone.amount.to_i)
        milestone.update_attributes(:payment_released => true, :pay_amount => milestone.amount.to_i)
      end
    else
      filmmaker.update_attribute(:balance, filmmaker.balance + milestone.amount.to_i)
      milestone.update_attributes(:payment_released => true, :pay_amount => milestone.amount.to_i)
    end
  end

  def message_participants
    @project = Project.where("id = ?",url_decode(params[:id])).first
    @recipients = Project.first.project_proposals.collect(&:filmmaker).collect(&:email)
    render :layout => 'popup'
  end

  def send_messages
    recipient_emails = params[:recipients].gsub(/\s+/, "").split(',')
    recipients = Filmmaker.where(email: recipient_emails).all
    unless recipients.blank?
      receipt = current_client.send_message(recipients, params[:body], params[:subject], params[:message_attachment])
      unless receipt.blank?
        notification = Notification.where("id = ?",receipt.notification_id).first
        notification.update_attribute(:attachment, params[:message_attachment]) unless params[:message_attachment].blank?
      end
      redirect_to "/view_proposals/#{url_encode(params[:project_id])}", :notice => 'Your Message was successfully sent.'
    else
      redirect_to "/view_proposals/#{url_encode(params[:project_id])}", :notice => 'Message has not been sent!'
    end
  end

  def fund_escrow_direct_hire_milestone
    milestone = DirectHireProposalMilestone.find(params[:id])
    @proposal = milestone.direct_hire_proposal
    project = @proposal.project
    @filmmaker = @proposal.filmmaker
    amount_after_balance = 0
    charge_client = false
    if milestone.present?
      if current_client.balance.to_i >= milestone.amount.to_i
        amount_after_balance = current_client.balance.to_i - milestone.amount.to_i
        current_client.update_attribute(:balance, amount_after_balance)
        if !project.is_filmmaker_working_in_project?
          ProjectDirectHire.create(:filmmaker_id => @filmmaker.id, :client_id => current_client.id, :direct_hire_proposal_id => @proposal.id)
        end
        milestone.update_attributes(:fund_escrowed => true, :escrowed_at => Time.now)
        flash[:success] = "Funding of milestone successful"
      else
        amount_to_charge = milestone.amount.to_i - current_client.balance.to_i
        account, msg = current_client.account_to_use
        case msg
        when 'credit_card' then
          credit_card_deposit(account, amount_to_charge.to_i, project, @filmmaker, @proposal, milestone, true)
        when 'bank_account' then
          bank_account_deposit(account, amount_to_charge.to_i, project, @filmmaker, @proposal, milestone, true)
        when 'no_default_account' then
          flash[:error] = "Default account could not be found"
        when 'no_default_backup_account' then
          flash[:error] = "Default account and Default backup account could not be found"
        when 'no_default_and_backup_account' then
          flash[:error] = "Please save an account as default account to add fund"
        end
      end
    else
      flash[:error] = "No milestone found to fund"
    end
    redirect_to :back
  end

  def release_payment_direct_hire_milestone
    milestone = DirectHireProposalMilestone.find(params[:id])
    @proposal = milestone.direct_hire_proposal
    project = @proposal.project
    @filmmaker = @proposal.filmmaker
    if milestone.present? && milestone.fund_escrowed
      admin_user = AdminUser.first
      admin_amount = milestone.amount.to_i / 10
      admin_user.update_attribute(:balance, admin_amount)
      filmmaker_amount = milestone.amount.to_i - admin_amount.to_i

      account, msg = @filmmaker.account_to_use
      case msg
        when 'credit_card' then
          credit_card_withdraw(account, filmmaker_amount.to_i, milestone, @filmmaker)
        when 'bank_account' then
          balance_account_withdraw(account, filmmaker_amount.to_i, milestone, @filmmaker)
        when 'no_default_account', 'no_default_backup_account', 'no_default_and_backup_account' then
          flash[:success] = "Payment has been released"
          @filmmaker.update_attribute(:balance, @filmmaker.balance + filmmaker_amount.to_i)
          milestone.update_attributes(:payment_released => true, :pay_amount => milestone.amount.to_i)
      end
    else
      flash[:error] = "Please fund the milestone in order to release funds"
    end
    redirect_to :back
  end

  def fund_escrow_updated_milestone
    milestone = UpdatedProjectProposalMilestone.find(params[:id])
    @proposal_revision = milestone.proposal_revision if milestone.present?
    @proposal = @proposal_revision.project_proposal if @proposal_revision.present?
    project = @proposal.project if @proposal.present?
    @filmmaker = @proposal.filmmaker if @proposal.present?
    amount_after_balance = 0
    charge_client = false
    if milestone.present?
      if current_client.balance.to_i >= milestone.amount.to_i
        amount_after_balance = current_client.balance.to_i - milestone.amount.to_i
        current_client.update_attribute(:balance, amount_after_balance)
        if !project.is_filmmaker_working_in_project?
          ProjectHire.create(:filmmaker_id => @filmmaker.id, :client_id => current_client.id, :proposal_id => @proposal.id, :proposal_revision_id => @proposal_revision.id)
        end
        milestone.update_attributes(:fund_escrowed => true, :escrowed_at => Time.now)
        flash[:success] = "Funding of milestone successful"
      else
        amount_to_charge = milestone.amount.to_i - current_client.balance.to_i
        account, msg = current_client.account_to_use
        case msg
          when 'credit_card' then
            credit_card_deposit(account, amount_to_charge.to_i, project, @filmmaker, @proposal, milestone)
          when 'bank_account' then
            bank_account_deposit(account, amount_to_charge.to_i, project, @filmmaker, @proposal, milestone)
          when 'no_default_account' then
            flash[:error] = "Default account could not be found"
          when 'no_default_backup_account' then
            flash[:error] = "Default account and Default backup account could not be found"
          when 'no_default_and_backup_account' then
            flash[:error] = "Please save an account as default account to add fund"
        end
      end
    else
      flash[:error] = "No milestone found to fund"
    end
    redirect_to :back
  end

  def release_payment_updated_milestone
    milestone = UpdatedProjectProposalMilestone.find(params[:id])
    proposal_revision = milestone.proposal_revision if milestone.present?
    @proposal = proposal_revision.project_proposal if proposal_revision.present?
    project = @proposal.project if @proposal.present?
    @filmmaker = @proposal.filmmaker if @proposal.present?
    if milestone.present? && milestone.fund_escrowed
      admin_user = AdminUser.first
      admin_amount = milestone.amount.to_i / 10
      admin_user.update_attribute(:balance, admin_amount)
      filmmaker_amount = milestone.amount.to_i - admin_amount.to_i
      account, msg = @filmmaker.account_to_use
      case msg
        when 'credit_card' then
          credit_card_withdraw(account, filmmaker_amount.to_i, milestone, @filmmaker)
        when 'bank_account' then
          balance_account_withdraw(account, filmmaker_amount.to_i, milestone, @filmmaker)
        when 'no_default_account', 'no_default_backup_account', 'no_default_and_backup_account' then
          flash[:success] = "Payment has been released"
          @filmmaker.update_attribute(:balance, @filmmaker.balance + filmmaker_amount.to_i)
          milestone.update_attributes(:payment_released => true, :pay_amount => milestone.amount.to_i)
      end
    else
      flash[:error] = "Please fund the milestone in order to release funds"
    end
    redirect_to :back
  end

end
