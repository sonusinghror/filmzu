class Filmmaker < ActiveRecord::Base

  acts_as_messageable
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

   # validates_presence_of :location , if: :on_portfolio_step?
   # validates_presence_of :photos, if: :on_portfolio_step?
   # validates_presence_of :demo_reel, if: :on_portfolio_step?
   # validates_presence_of :skills, if: :on_portfolio_step?
   # validates_presence_of :about, if: :on_portfolio_step?

  has_one :user, as: :meta, dependent: :destroy

  has_many :milestones
  has_one :profile, :dependent => :destroy
  has_many :friends, through: :friendships
  has_many :photos, :as => :imageable, :dependent => :destroy, :conditions => { :is_cover => false }
  has_one :resume, :class_name => 'UploadedDocument', :as => :documentable, :dependent => :destroy
  has_one :cover_photo, :class_name =>'Photo' , :as => :imageable, :dependent => :destroy, :conditions => { :is_cover => true }
  has_many :conversations
  has_one :demo_reel, :class_name => 'Video', :as => :videoable, :dependent => :destroy, :conditions => { :is_demo_reel => true }
  has_many :other_videos, :class_name => 'Video', :as => :videoable, :dependent => :destroy, :conditions => { :is_demo_reel => false }
  # this gives all videos incluing demo reel and other videos
  has_many :videos, :as => :videoable, :dependent => :destroy

  has_many :projects#, :dependent => :destroy
  has_many :project_feedbacks, :class_name => 'ProjectFeedback', :foreign_key => :filmmaker_id, :dependent => :destroy
  has_many :events#, :dependent => :destroy
  has_many :talents#, :dependent => :destroy
  has_many :project_hires, :dependent => :destroy
  has_many :friendships
  has_many :likes

  accepts_nested_attributes_for :user, :resume, :photos, :videos

  has_many :follows, class_name: "Friendship", foreign_key: "friend_id"
  has_many :followers, through: :follows, source: :user, foreign_key: "friend_id"

	has_one :pro_account, :as => :accountable
	has_many :project_blacklists, :dependent => :destroy
	has_many :project_proposals, :foreign_key => 'filmmaker_id', :class_name => 'ProjectProposal', :dependent => :destroy

  has_many :direct_hires, dependent: :destroy
	has_many :filmmaker_feedbacks
	has_many :bank_accounts, :as => :bank_accountable
	has_many :credit_cards, :as => :card_accountable
  has_many :deposits, as: :depositable
  has_many :withdraws, as: :withdrawable
  has_many :project_direct_hires

  acts_as_taggable_on :skill

  validate :skill_list_count
  validate :unique_email

  def skill_list_count
    errors[:skill_list] << "8 tags maximum" if skill_list.count > 8
  end

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me,
   :confirmed_at , :skills , :about , :location , :latitude , :longitude, :balanced_uri ,
   :photo, :rate, :is_company, :company, :resume, :provider, :uid, :oauth_token, :oauth_expires_at,
   :fb_token, :location, :linkedin_token, :skill_list, :resume_attributes, :default_account, :default_account_type,
   :default_backup_account, :default_backup_account_type, :verified, :verified_by_admin, :videos_attributes, :photos_attributes

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


  after_create do |filmmaker|
    begin
      if filmmaker.balanced_uri.blank?
        customer = Balanced::Customer.new(
          :email => filmmaker.email,
          :name => filmmaker.name
        )
        customer.save
        filmmaker.update_attribute(:balanced_uri, customer.attributes['href'])
      end
    rescue
      Rails.logger.info 'Balanced customer entry could not be created for filmmaker'
    end
    FilmmakerMailer.delay.signup_confirmation(filmmaker)
  end

  def self.admin_dashboard_entries
    Filmmaker.order('created_at DESC').limit(5)
  end

  geocoded_by :location
  after_validation :geocode

  def role?(role)
      return !!self.roles.find_by_name(role.to_s.camelize)
  end

	# make database entry for project blacklist
	def blacklist_project project_id, filmmaker_id
		project = Project.find(project_id)
		project.project_blacklists.create(:filmmaker_id => filmmaker_id, :blocked_at => Time.now)
		return
	end

  # def on_page_portfolio

  # end

   def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |filmmaker|
      filmmaker.provider = auth.provider
      filmmaker.uid = auth.uid
      filmmaker.name = auth.info.name
      filmmaker.oauth_token = auth.credentials.token
      filmmaker.oauth_expires_at = Time.at(auth.credentials.expires_at)
      filmmaker.email = auth.info.email
      filmmaker.save!
    end
  end

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    ## debugger
    filmmaker = Filmmaker.where(:provider => auth.provider, :uid => auth.uid).first
    # puts auth.inspect
    if filmmaker.nil?
      filmmaker = Filmmaker.create(name:auth.extra.raw_info.name,
                           provider:auth.provider,
                           uid:auth.uid,
                           email:auth.info.email,
                           password:Devise.friendly_token[0,20].camelize + '_123',
                           fb_token: auth.credentials.token)
    else
      filmmaker.update_attributes(fb_token: auth.credentials.token)
    end
    filmmaker
  end

  def send_notification_mails

  end

  def self.find_for_linkedin_oauth(auth, signed_in_resource=nil)
    ## debugger
    filmmaker = Filmmaker.where(:provider => auth.provider, :uid => auth.uid).first
    # puts auth.inspect
    if filmmaker.nil?
      filmmaker = Filmmaker.create(name:auth.extra.raw_info.name,
                           provider:auth.provider,
                           uid:auth.uid,
                           email:auth.info.email,
                           password:Devise.friendly_token[0,20].camelize + '_123',
                           linkedin_token: auth.credentials.token)
    else
      filmmaker.update_attributes(linkedin_token: auth.credentials.token)
    end
    filmmaker
  end

  def header_photo
    if profile.present? && profile.image.present?
      profile.image.tiny
    elsif photos.present?
      photos.last.image.tiny
    else
      "/assets/fallback/Filmmaker_small_default.png"
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

  def completeness
    check_array = ["id", "name", "email", "location", "about", "skills", "rate", "videos", "resume", "photos"]
    puts check_array
    present_sum = check_array.map { |prop|
      if self.send(prop).present?
        1
      else
        0
      end
    }.reduce(:+)
    puts present_sum
    total_props = check_array.size # + 5
    puts total_props
    ((present_sum.to_f/total_props.to_f) * 100).to_i
  end

  def self.populate_skill_list
    filmmakers = Filmmaker.where("skills IS NOT NULL")
    filmmakers.all.each do |filmmaker|
      skill_list = filmmaker.skills
      if filmmaker.update_attributes(:skill_list => skill_list)
        puts "\nFilmmaker skill list population success: #{filmmaker.id}\n"
      else
        puts "\nFilmmaker skill list population failure: #{filmmaker.id}\n"
      end
    end
  end

  def document_name
    if (resume.present? && (doc = resume.document))
     (doc.present? && doc.file.present?) ? doc.file.filename : ""
    end
  end

  def hired_in_project(project_proposal)
    !(ProjectHire.where("proposal_id = ? AND filmmaker_id = ?",project_proposal.id,self.id).first.blank?)
  end

  def make_first_pro_account_transaction
    status = false
    msg = ''
    if self.default_account.present? && self.default_account_type.present?
      if self.default_account_type == 'c'
        status, msg = self.credit_card_deposit(self.default_account, 9)
      elsif self.default_account_type == 'b'
        status, msg = self.bank_account_deposit(self.default_account, 9)
      else
        status = false
        msg = "No default account found"
      end
    else
      if self.default_backup_account.present? && self.default_backup_account_type.present?
        if self.default_backup_account_type == 'c'
          status, msg = self.credit_card_deposit(self.default_backup_account, 9)
        elsif self.default_backup_account_type == 'b'
          status, msg = self.bank_account_deposit(self.default_backup_account, 9)
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

  def bank_account_deposit(bank_account_id, amount)
    default_account = self.bank_accounts.where(id: bank_account_id).first
    if default_account.present?
      bank_account = Balanced::BankAccount.fetch(default_account.bank_account_uri)
      response = bank_account.debit(
        :amount => amount.to_i * 100,
        :appears_on_statement_as => "Fund on #{Time.now.strftime('%d %b %Y')}",
        :description => "Fund on #{Time.now.strftime('%d %b %Y')}",
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
      if debits['failure_reason_code'].present? || debits['failure_reason'].present?
        deposit = self.deposits.create(deposit_hash)
        return false, "#{debits['failure_reason']}"
      else
        deposit_hash.merge!({pro: true})
        deposit = self.deposits.create(deposit_hash)
        return true, "Upgrade to pro transaction was successfully"
      end
    else
      return false, "Upgrade to pro could not be done. Please retry"
    end
  end

  def credit_card_deposit(credit_card_id, amount)
    default_account = self.credit_cards.where(id: credit_card_id).first
    if default_account.present?
      credit_card = Balanced::Card.fetch(default_account.credit_card_uri)
      response = credit_card.debit(
        :amount => amount.to_i * 100,
        :appears_on_statement_as => "Fund on #{Time.now.strftime('%d %b %Y')}",
        :description => "Fund on #{Time.now.strftime('%d %b %Y')}",
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
      if debits['failure_reason_code'].present? || debits['failure_reason'].present?
        deposit = self.deposits.create(deposit_hash)
        return false, "#{debits['failure_reason']}"
      else
        deposit_hash.merge!({pro: true})
        deposit = self.deposits.create(deposit_hash)
        return true, "Upgrade to pro transaction was successfully"
      end
    else
      return false, "Upgrade to pro could not be done. Please retry"
    end
  end

  def is_pro?
    if self.pro_account.present? && self.pro_account.account_type == 'pro'
      true
    else
      false
    end
  end

  def own_projects
    pr_projects = project_proposals.where(is_approved: true).uniq.collect(&:project)
    dr_projects = direct_hires.collect(&:direct_hire_proposal).uniq.collect(&:project)
    (pr_projects + dr_projects).reject(&:blank?).uniq
  end

  def project_milestones(project)
    proposal = project_proposals.where(project_id: project.id).first
    if proposal.present?
      if proposal.is_modified && proposal.is_approved && !proposal.proposal_revisions.blank?
        last_revision = proposal.proposal_revisions.last
        milestones = last_revision.updated_project_proposal_milestones.order("created_at ASC")
        return [proposal, milestones, true]
      else
        milestones = proposal.project_proposal_milestones.order("created_at ASC")
        return [proposal, milestones, true]
      end
    else
      dr_proposal = DirectHireProposal.where(filmmaker_id: self.id, project_id: project.id).first
      if dr_proposal.present?
        milestones = dr_proposal.direct_hire_proposal_milestones.order("created_at ASC")
        return [dr_proposal, milestones]
      else
       return [nil, nil, false]
      end
    end
  end

  def project_stats(stat_type)
    proposal_projects = self.project_proposals.where("is_approved = ?",true).collect(&:project).reject(&:blank?)
    project_ids = self.direct_hires.collect(&:direct_hire_proposal).select { |dhp| (dhp.project_id != nil && dhp.is_approved == true) }.collect(&:project_id)
    direct_hire_projects = Project.where("id IN (?)",project_ids)
    case stat_type
      when 'completed_projects'
        proposal_projects.select { |project| project.status == "Completed" } + direct_hire_projects.select { |project| project.status == "Completed" }
      when 'awarded_projects'
        proposal_projects + direct_hire_projects
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

private
  def unique_email
    errors.add(:email, 'This Email is taken') unless Client.where(email: self.email).blank?
  end
end
