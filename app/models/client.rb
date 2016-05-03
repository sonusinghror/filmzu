class Client < ActiveRecord::Base

  acts_as_messageable
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_one :user, as: :meta, dependent: :destroy
  accepts_nested_attributes_for :user

  has_many :milestones
  has_one :profile, :dependent => :destroy

  has_many :friends, through: :friendships
  has_many :photos, :as => :imageable, :dependent => :destroy, :conditions => { :is_cover => false }
  has_one :resume, :class_name => 'UploadedDocument', :as => :documentable, :dependent => :destroy
  has_one :cover_photo, :class_name =>'Photo' , :as => :imageable, :dependent => :destroy, :conditions => { :is_cover => true }
  has_many :conversations
  has_one :demo_reel, :class_name => 'Video', :as => :videoable, :dependent => :destroy, :conditions => { :is_demo_reel => true }
  has_many :other_videos, :class_name => 'Video', :as => :videoable, :dependent => :destroy, :conditions => { :is_demo_reel => false }
  has_many :videos, :as => :videoable, :dependent => :destroy

  has_many :projects, :class_name => 'Project', :foreign_key => :user_id ,:dependent => :destroy
  has_many :project_hires, :class_name => 'ProjectHire', :foreign_key => :client_id ,:dependent => :destroy
  has_many :project_feedbacks, :class_name => 'ProjectFeedback', :foreign_key => :client_id, :dependent => :destroy
  has_many :filmmaker_feedbacks, :class_name => 'FilmmakerFeedback', :foreign_key => :client_id, :dependent => :destroy
  has_many :events#, :dependent => :destroy
  has_many :talents#, :dependent => :destroy
  has_many :friendships
  has_many :likes

  has_many :follows, class_name: "Friendship", foreign_key: "friend_id"
  has_many :followers, through: :follows, source: :user, foreign_key: "friend_id"
  has_many :bank_accounts, :as => :bank_accountable
  has_many :credit_cards, :as => :card_accountable
  has_many :direct_hire_proposals
  has_one :pro_account, :as => :accountable

  has_many :deposits, as: :depositable
  has_many :withdraws, as: :withdrawable
  has_many :project_direct_hires

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me,
  :confirmed_at, :balanced_uri, :provider, :uid, :oauth_token, :oauth_expires_at,
  :fb_token, :location, :linkedin_token, :default_account, :default_backup_account, :default_account_type, :default_backup_account_type

  include Mailboxer::Models::Messageable
  acts_as_messageable
  #Returning the email address of the model if an email should be sent for this object (Message or Notification).
  #If no mail has to be sent, return nil.
  def mailboxer_email(object)
    #Check if an email should be sent for that object
    if send_notification_mails == true
      return email
    else
      return nil
    end
  end

  def send_notification_mails
  end

  def self.admin_dashboard_entries
    Client.order('created_at DESC').limit(5)
  end

  after_create do |client|
    begin
      if client.balanced_uri.blank?
        customer = Balanced::Customer.new(
          :email => client.email,
          :name => client.name
        )
        customer.save
        client.update_attribute(:balanced_uri, customer.attributes['href'])
      end
    rescue
      Rails.logger.info 'Balanced customer entry could not be created for client'
    end
    ClientMailer.delay.signup_confirmation(client)
    # ClientMailer.welcome_email(client).deliver
  end

  geocoded_by :location
  after_validation :geocode

  def recent_projects(param = {})
    if param.has_key?(:search_name)
     self.projects.where("LOWER(title) like ?","#{param[:search_name]}%").order('created_at desc')
    else
      self.projects.order('created_at desc')
    end
  end

  def proposed_projects
    ProjectProposal.includes(:project).where("id in (?)",self.project_hires.pluck(:proposal_id))
  end

  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |client|
      client.provider = auth.provider
      client.uid = auth.uid
      client.name = auth.info.name
      client.oauth_token = auth.credentials.token
      client.oauth_expires_at = Time.at(auth.credentials.expires_at)
      client.email = auth.info.email
      client.save!
    end
  end

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    ## debugger
    client = Client.where(:provider => auth.provider, :uid => auth.uid).first
    # puts auth.inspect
    if client.nil?
      client = Client.create(name:auth.extra.raw_info.name,
                           provider:auth.provider,
                           uid:auth.uid,
                           email:auth.info.email,
                           password:Devise.friendly_token[0,20].camelize + '_123',
                           fb_token: auth.credentials.token)
    else
      client.update_attributes(fb_token: auth.credentials.token)
    end
    client
  end

  def self.find_for_linkedin_oauth(auth, signed_in_resource=nil)
    ## debugger
    client = Client.where(:provider => auth.provider, :uid => auth.uid).first
    # puts auth.inspect
    if client.nil?
      client = Client.create(name:auth.extra.raw_info.name,
                           provider:auth.provider,
                           uid:auth.uid,
                           email:auth.info.email,
                           password:Devise.friendly_token[0,20].camelize + '_123',
                           linkedin_token: auth.credentials.token)
    else
      client.update_attributes(linkedin_token: auth.credentials.token)
    end
    client
  end

  validate :unique_email

  def header_photo
    if profile.present? && profile.image.present?
      profile.image.tiny
    elsif photos.present?
      photos.last.image.tiny
    else
      "../assets/fallback/Filmmaker_small_default.png"
    end
  end

  def profile_photo
    if profile.present? && profile.image.present?
      profile.image.medium
    elsif photos.present?
      photos.last.image.medium
    else
      "../assets/fallback/Filmmaker_medium_default.png"
    end
  end

  def featured_project_payment(project)
    status = false
    msg = ''
    if self.default_account.present? && self.default_account_type.present?
      if self.default_account_type == 'c'
        status, msg = self.credit_card_deposit(self.default_account, 15, project)
      elsif self.default_account_type == 'b'
        status, msg = self.bank_account_deposit(self.default_account, 15, project)
      else
        status = false
        msg = "No default account found"
      end
    else
      if self.default_backup_account.present? && self.default_backup_account_type.present?
        if self.default_backup_account_type == 'c'
          status, msg = self.credit_card_deposit(self.default_backup_account, 15, project)
        elsif self.default_backup_account_type == 'b'
          status, msg = self.bank_account_deposit(self.default_backup_account, 15, project)
        else
          status = false
          msg = "No default account or default backup account"
        end
      else
        status = false
        msg = "No default account or default backup account"
      end
    end
    return status, msg
  end

  def bank_account_deposit(bank_account_id, amount, project)
    default_account = self.bank_accounts.where(id: bank_account_id).first
    if default_account.present?
      begin
        bank_account = Balanced::BankAccount.fetch(default_account.bank_account_uri)
        response = bank_account.debit(
          :amount => amount.to_i * 100,
          :appears_on_statement_as => "Featured #{Time.now.strftime('%d %b %Y')}",
          :description => "Featured #{Time.now.strftime('%d %b %Y')}",
          :source_uri => default_account.bank_account_uri
        )
        debits = response.attributes
        deposit_hash ={
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
        deposit = self.deposits.create(deposit_hash)
        if debits['failure_reason_code'].present? || debits['failure_reason'].present?
          return false, "#{debits['failure_reason']}"
        else
          project.update_attributes(:is_featured => true, :featured_payment_status => true)
          return true, "Your project is now featured"
        end
      rescue Exception => e
        return false, "Project could not be featured"
      end
    else
      return false, "Featuring project was not successful. Please retry"
    end
  end

  def credit_card_deposit(credit_card_id, amount, project)
    default_account = self.credit_cards.where(id: credit_card_id).first
    if default_account.present?
      begin
        credit_card = Balanced::Card.fetch(default_account.credit_card_uri)
        response = credit_card.debit(
          :amount => amount.to_i * 100,
          :appears_on_statement_as => "Featured #{Time.now.strftime('%d %b %Y')}",
          :description => "Featured #{Time.now.strftime('%d %b %Y')}",
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
        deposit = self.deposits.create(deposit_hash)
        if debits['failure_reason_code'].present? || debits['failure_reason'].present?
          return false, "#{debits['failure_reason']}"
        else
          project.update_attributes(:is_featured => true, :featured_payment_status => true)
          return true, "Your project is now featured"
        end
      rescue Exception => e
        return false, "Project could not be featured"
      end
    else
      return false, "Featuring project was not successful. Please retry"
    end
  end

  def account_to_use
    if self.default_account.present? && self.default_account_type.present?
      if self.default_account_type == 'c'
        [self.default_account, 'credit_card']
      elsif self.default_account_type == 'b'
        [self.default_account, 'bank_account']
      else
        [false, 'no_default_account']
      end
    else
      if self.default_backup_account.present? && self.default_backup_account_type.present?
        if self.default_backup_account_type == 'c'
          [self.default_backup_account, 'credit_card']
        elsif self.default_backup_account_type == 'b'
          [self.default_backup_account, 'bank_account']
        else
          [false, 'no_default_backup_account']
        end
      else
        [false, 'no_default_and_backup_account']
      end
    end
  end

  def notifications
    proposals = proposal_receipts.collect(&:id) rescue nil
    if proposals.blank?
      return [] 
    else
      receipts.where("notification_id NOT IN (?)", proposals).is_unread.try(:count)
    end  
  end

  def proposal_receipts
    messages = []
    mailbox.conversations.each {|conv| messages << conv.messages.reject{|msg| !(msg.subject == "Project Proposal") } }
    messages.flatten!
  end  
    
  def unread_notifications_count
    count = 0
    conversation_ids = self.receipts.is_unread.collect(&:notification_id)
    count = Conversation.where("subject!=? AND id IN (?)", 'Project Proposal', conversation_ids).count if conversation_ids.present?
    count
  end

private
  def unique_email
    errors.add(:email, 'This Email is taken') unless Filmmaker.where(email: self.email).blank?
  end
end
