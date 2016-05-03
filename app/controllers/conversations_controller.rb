class ConversationsController < ApplicationController

  #load_and_authorize_resource

  before_filter :search, :except => [:send_message_generic]
  helper_method :mailbox, :conversation

  def new

    # @friends = current_user.friends.pluck('email')

    @friends = Client.all.select("clients.*, clients.name AS label").map{|user|
      {
        "label" => user.name,
        "value" => user.email,
        "desc" => user.email
      }
    }

    @recipient = params[:recipient]
    @subject  = params[:subject] if params[:subject]

    if params[:modal]
      @modal = true
      respond_to do |format|
        format.html { render :layout => false }# show.html.erb
      end
    end
  end

  def create
    # Standard Part
    recipient_emails = params[:recipients].gsub(/\s+/, "").split(',') # remove any spaces that are present in the params
    # recipient_emails = conversation_params(:recipients).split(',')
    recipients = User.where(email: recipient_emails).all

    current_user.send_message(recipients, params[:message], params[:conversation][:subject])

    redirect_to "/dashboard#messages", :notice => 'Your Message was successfully sent.'
  end

  def send_message_generic
    recipient_emails = params[:recipients].split(',')
    recipient_emails.delete('') # deleting empty email if any..
    recipients = User.where(email: recipient_emails).all
    subject = params[:subject]
    message = params[:message]
    current_user.send_message(recipients, message, subject)
    render :text => true
  end

  # Destroy Message form the System
  def destroy
    Notification.find(params[:id]).destroy
    respond_to do |format|
      format.html { redirect_to admin_admin_messages_url, :notice => 'Message has been deleted' }
    end
  end

  def reply
     conversation = Conversation.find(params[:id])
     # alfa.reply_to_conversation((conversation, *message_params(:body, :subject))
     # alfa = current_filmmaker/current_client
     # body = params[:reply][:text]
     alfa = current_client || current_filmmaker

     case alfa
     when current_client
       current_client.reply_to_conversation(conversation, params[:reply][:text])
      body = params[:reply][:text]
     when current_filmmaker
       current_filmmaker.reply_to_conversation(conversation, params[:reply][:text])
        body = params[:reply][:text]
     end

    respond_to do |format|
      format.html { redirect_to :conversation }
      format.json { render :json => receipt.message.to_json(:include => [:sender]) }
    end
  end

  def trash
    conversation.move_to_trash(current_user)
    respond_to do |format|
      format.html { redirect_to :conversation }
      format.json { render :text => true }
    end
  end

  def untrash
    conversation.untrash(current_user)
    respond_to do |format|
      format.html { redirect_to :conversation }
      format.json { render :text => true }
    end
  end

  def empty_trash
    current_user.mailbox.trash.destroy_all
    render :text => true
  end

  #Bring in Details from Documentation Here Also Add to Routes
  def unread
    conversation.mark_as_unread(current_user)
    redirect_to :conversations
  end

  def read
    conversation.mark_as_read(current_user)
    respond_to do |format|
      format.html { redirect_to :conversation }
      format.json { render :text => true }
    end
  end

  def get_messages
    this_conversation = Conversation.find(params[:id])

    ids = this_conversation.receipts_for( current_user ).pluck('notification_id')
    messages = Notification.where( :type => 'Message', :id => ids )

    # mark conversation read for this user, since he has requested to see messages
    conversation.mark_as_read(current_user)

    respond_to do |format|
      format.json { render :json => messages.to_json(:include => [:sender], :check_user => current_user) }
    end
  end

  def show
    #{"client_id"=>"2", "id"=>"5"}

    @conversation = Message.find(params[:id])
    @conversation_obj = @conversation.conversation
    message = @conversation
    @sender_type = ""
    @msg_content_type = ""

    message_sender = message.sender_type.eql?("Filmmaker") ? Filmmaker.find(params[:filmmaker_id]) : Client.find(params[:client_id])

    if message_sender.class.to_s.eql?("Client") && !message.subject.include?("RE") && message.subject.include?("Direct Hire") # CONDITION TO LOAD DIRECT HIRE PROPOSAL CONTENT IF A FILMMAKER

    @msg_content_type = "proposal"
          filmmaker = message_sender
          proposal = DirectHireProposal.where(:client_id => message.sender_id, :filmmaker_id => current_filmmaker.id).first

          @response_data = {}
          client = Client.find(message.sender_id)

          client_details = {
            :name => client.name,
            :location => client.location,
            :sent_at => proposal.created_at.utc.strftime("%H:%M %P")
          }

          proposal_details = {
            :dates => [proposal.desired_start_date.strftime("%B %d -"), proposal.desired_end_date.strftime("%B %d, %Y")],
            :cover_letter => proposal.cover_letter,
          }

          milestone_details = []
          proposal.direct_hire_proposal_milestones.each do |milestone|
            milestone_details << {:name => milestone.name, :delivery_date => milestone.delivery_date, :amount => milestone.amount.to_i}
          end

          @response_data[:filmmaker_details] = client_details
          @response_data[:proposal_details]  = proposal_details
          @response_data[:milestone_details] =  milestone_details
          @response_data[:total] = proposal.direct_hire_proposal_milestones.sum(:amount).to_i

          @proposal = proposal


    else

       # CODE TO GET THE MESSAGE CONTENT(SIMPLE TEXT MESSAGE WITH SUBJECT & BODY)
        @msg_content_type = "message"


        msg_name = {
        :name => message_sender.name
        }
        msg_location = {
        :location => message_sender.location
        }

        msg_subject = {
        :subject => message.subject
        }

        msg_body = {
        :body => message.body
        }

        msg_sent ={
        :sent_at => message.created_at.strftime("%H:%M %P")
        }

        msg_image ={
        :image => message_sender.photos
        }

        @response_data = {}
        @response_data[:name] = message_sender.name
        @response_data[:location] = message_sender.location
        @response_data[:subject] = message.subject
        @response_data[:body] = message.body
        @response_data[:sent_at] = message.created_at.strftime("%H:%M %P")
        @response_data[:image] = message_sender.profile_photo
      end



    respond_to do |format|
      format.js
    end
  end

  private

  def mailbox
    @mailbox ||= current_user.mailbox
  end
  # Mark as read once Conversation has been opened.
  def conversation
    mailbox.conversations.find(params[:id]).receipts_for(current_user).mark_as_read
    @conversation ||= mailbox.conversations.find(params[:id])
  end

  def conversation_params(*keys)
    fetch_params(:conversation, *keys)
  end

  def message_params(*keys)
    fetch_params(:message, *keys)
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
