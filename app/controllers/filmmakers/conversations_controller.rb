class Filmmakers::ConversationsController < ApplicationController

  #load_and_authorize_resource
  before_filter :authenticate_filmmaker!
  
  before_filter :search, :except => [:send_message_generic, :new]
  before_filter :load_messages, :only => [:index, :new, :create, :show]
  helper_method :mailbox, :conversation

   def new
      @recipient = params[:recipient]
      @subject  = params[:subject] if params[:subject]
     # @request = Request.find(params[:request])
      @message = current_filmmaker.messages.new
      @filmmaker = current_filmmaker
  end

  def show
    @conversation =  Message.find(params[:message_id]) #mailbox.conversations.find(params[:id])
     respond_to do |format|
       format.html # index.html.erb
       format.js { render :layout => false }
     end  
  end
  
  def index
      @conversation = mailbox.inbox.first.messages.first unless mailbox.inbox.empty?
  end
  
  def get_inbox_messages
    messages = []
    current_filmmaker.mailbox.inbox.each{|conv| messages << conv.messages.reject {|message| message.subject == "Project Proposal"} }
    messages.flatten
  end

  def get_sent_messages
    messages = []
    current_filmmaker.mailbox.sentbox.each{|conv| messages << conv.messages.reject {|message| message.subject == "Project Proposal"} }
    messages.flatten
  end

  def get_trashed_messages
    messages = []
    current_filmmaker.mailbox.trash.each{|conv| messages << conv.messages.reject {|message| message.subject == "Project Proposal"} }
    messages.flatten
  end
  
  # def index
  #   @filmmaker = current_filmmaker
  #   respond_to do |format|
  #     format.html # index.html.erb
  #     format.json { render json: @filmmakers }
  #   end
  # end

  def create
    recipient_emails = params[:recipients]
    @recipients = Client.where(email: recipient_emails).to_a
    @recipient = Client.find(url_decode(params[:to_c])) if params[:to_c].present?
    @recipients.push(@recipient) if @recipient.present?
    if params[:body].present? && params[:subject].present?
      if !@recipients.blank?
        #current_filmmaker.send_message(recipients, params[:body], params[:subject], params[:file])
        current_filmmaker.send_message(@recipients, params[:body], params[:subject], true, params[:file], Time.now)
        flash[:notice] = 'Message has been sent!'
        redirect_to "/filmmakers/messages" and return
      else
        if request.post?
          flash[:alert] = "Message has not been sent!" 
          redirect_to :back
        end
      end
    else
      if request.post?
        flash[:alert] = "Subject and Message body are mandatory fields"
        redirect_to :back
      end
    end
    if request.get?
      respond_to do |format|
         format.html
         format.js { render :layout => false }
      end 
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
      res = current_filmmaker.reply_to_conversation(conversation, params[:message], nil, true, true, params[:proposal_attachment])
    else
      res = current_filmmaker.reply_to_conversation(conversation, params[:message])
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
    conversation.move_to_trash(current_filmmaker)
    load_messages
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render :layout => false }
    end
  end

  def untrash
    conversation.untrash(current_filmmaker)
    load_messages
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render :layout => false }
    end
  end

  def unread
    conversation.mark_as_unread(current_filmmaker)
    redirect_to :conversations
  end

  def read
    conversation.mark_as_read(current_filmmaker)
    respond_to do |format|
      format.html { redirect_to :conversation }
      format.json { render :text => true }
    end
  end

  def get_messages
    this_conversation = Conversation.find(params[:id])

    ids = this_conversation.receipts_for( current_filmmaker ).pluck('notification_id')
    messages = Notification.where( :type => 'Message', :id => ids )

    # mark conversation read for this user, since he has requested to see messages
    conversation.mark_as_read(current_filmmaker)
    
    respond_to do |format|
      format.json { render :json => messages.to_json(:include => [:sender], :check_user => current_filmmaker) }
    end
  end

   def send_message_generic
    recipient_emails = params[:recipients].split(',')
    recipient_emails.delete('') # deleting empty email if any..
    recipients = Client.where(email: recipient_emails).all
    subject = params[:subject]
    message = params[:message]
    current_filmmaker.send_message(recipients, message, subject)
    render :text => true
  end
   private

  def mailbox
    @mailbox ||= current_filmmaker.mailbox
  end
   
  def conversation
    mailbox.conversations.find(params[:id]).receipts_for(current_filmmaker).mark_as_read
    @conversation ||= mailbox.conversations.find(params[:id])    
  end

  def conversation_params(*keys)
    fetch_params(:conversation, *keys)
  end

  def message_params(*keys)
    fetch_params(:message, *keys)
  end

  def load_messages
    #@conversations ||= current_filmmaker.mailbox.inbox.all
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
