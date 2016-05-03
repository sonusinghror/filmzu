class Clients::ConversationsController < ApplicationController

  # load_and_authorize_resource
  before_filter :authenticate_client!
  before_filter :search, :except => [:send_message_generic]
  before_filter :load_messages, :only => [:index, :new, :create]
  helper_method :mailbox, :conversation

  def new
    @recipient = params[:recipient]
    @subject  = params[:subject] if params[:subject]
    # @request = Request.find(params[:request])
    @message = current_client.messages.new
    @client = current_user
  end

  def show
    #@conversation ||= mailbox.conversations.find(params[:client_id])
    respond_to do |format|
      format.js  
    end
  end

  def inbox_proposal
    @recipient = params[:recipient]
    @subject  = params[:subject] if params[:subject]
  end

  def index
    @inbox_messages = Kaminari.paginate_array(get_inbox_messages).per_page_kaminari(params[:page]).per(5)
    @sent_messages = Kaminari.paginate_array(get_sent_messages).per_page_kaminari(params[:page]).per(5)
    @trashed_messages = Kaminari.paginate_array(get_trashed_messages).per_page_kaminari(params[:page]).per(5)
    if @inbox_messages.first.present?
      @inbox_messages.first.mark_as_read(current_client)
      @conversation = @inbox_messages.first
    end
  end

  def get_inbox_messages
    messages = []
    current_client.mailbox.inbox.each{|conv| messages << conv.messages.reject {|message| message.subject == "Project Proposal"} }
    messages.flatten
  end

  def get_sent_messages
    messages = []
    current_client.mailbox.sentbox.each{|conv| messages << conv.messages.reject {|message| message.subject == "Project Proposal"} }
    messages.flatten
  end

  def get_trashed_messages
    messages = []
    current_client.mailbox.trash.each{|conv| messages << conv.messages.reject {|message| message.subject == "Project Proposal"} }
    messages.flatten
  end

  def create
    #raise params[:message_attachment].inspect if request.post?
   # filmmaker_ids = current_client.projects.collect(&:project_proposals).flatten.collect(&:filmmaker_id).uniq
    @client_recipients = Filmmaker.all#.where("id IN (?)",filmmaker_ids)
    @recipient = Filmmaker.find(url_decode(params[:to_f])) if params[:to_f].present?
    recipient_emails = params[:recipients]
    recipients = Filmmaker.where(email: recipient_emails).to_a
    # redirect_to :path_to_redirect
    if params[:body].present? && params[:subject].present?
      if recipients.present?
        #current_client.send_message(recipients, params[:body], params[:subject])
        receipt = current_client.send_message(recipients, params[:body], params[:subject], true, params[:message_attachment], Time.now)
        unless receipt.blank?
          notification = Notification.where("id = ?",receipt.notification_id).first
          notification.update_attribute(:attachment, params[:message_attachment]) unless params[:message_attachment].blank?
        end  
        redirect_to "/clients/messages", notice: 'Message has been sent!'
      else
        flash[:alert] = "Message has not been sent!" if request.post?
      end
    else
      flash[:alert] = "Subject and Message body are mandatory fields" if request.post?
    end
  end

  def destroy
    Notification.find(params[:id]).destroy
    respond_to do |format|
      format.html { redirect_to admin_admin_messages_url, :notice => 'Message has been deleted' }
    end
  end

   def reply
    if params[:proposal_attachment].present?
      res = current_client.reply_to_conversation(conversation, params[:message], nil, true, true, params[:proposal_attachment])
    else
      res = current_client.reply_to_conversation(conversation, params[:message])
    end
    @conversation = Message.find(res.notification_id) if res.present? && res.notification_id.present?
    #redirect_to conversation
    load_messages
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render :layout => false }
    end
  end

  def trash
    conversation.move_to_trash(current_client)
    load_messages
    respond_to do |format|
      format.js
    end
  end

  def untrash
    conversation.untrash(current_client)
    load_messages
    respond_to do |format|
      format.js
    end
  end

  def unread
    conversation.mark_as_unread(current_client)
    redirect_to :conversations
  end

  def read
    conversation.mark_as_read(current_client)
    respond_to do |format|
      format.html { redirect_to :conversation }
      format.json { render :text => true }
    end
  end

  def delete_permanently
    conversation.mark_as_deleted(current_client)
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render :text => true }
    end    
  end  

  def get_messages
    this_conversation = Conversation.find(params[:id])

    ids = this_conversation.receipts_for( current_client ).pluck('notification_id')
    messages = Notification.where( :type => 'Message', :id => ids )

    # mark conversation read for this user, since he has requested to see messages
    conversation.mark_as_read(current_client)

    respond_to do |format|
      format.json { render :json => messages.to_json(:include => [:sender], :check_user => current_client) }
    end
  end

  def send_message_generic
    recipient_emails = params[:recipients].split(',')
    recipient_emails.delete('') # deleting empty email if any..
    recipients = Filmmakers.where(email: recipient_emails).all
    subject = params[:subject]
    message = params[:message]
    current_user.send_message(recipients, message, subject)
    render :text => true
  end

private
  def mailbox
    @mailbox ||= current_client.mailbox
  end

  def conversation
    unless params[:message_id].present?  
      mailbox.conversations.find(params[:id]).receipts_for(current_client).mark_as_read
      @conversation ||= mailbox.conversations.find(params[:id])
    else
      message = Message.where("id = ?",params[:message_id]).first
      message.mark_as_read(current_client)
      @conversation ||= message     
    end  
  end

  def conversation_params(*keys)
    fetch_params(:conversation, *keys)
  end

  def message_params(*keys)
    fetch_params(:message, *keys)
  end

  def load_messages
    @inbox_messages = Kaminari.paginate_array(get_inbox_messages.reverse).per_page_kaminari(params[:page]).per(5)
    @sent_messages = Kaminari.paginate_array(get_sent_messages.reverse).per_page_kaminari(params[:page]).per(5)
    @trashed_messages = Kaminari.paginate_array(get_trashed_messages.reverse).per_page_kaminari(params[:page]).per(5)
  end

  def fetch_params(key, *subkeys)
    params[key].instance_eval do
      case subkeys.size
      when 0 then self
      when 1 then self[subkeys.first]
      else subkeys.map{|k| self[k] }
      end
    end
  end
end
