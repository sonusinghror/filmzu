class Project < ActiveRecord::Base
  include PublicActivity::Common
  include ActionView::Helpers

  # tracked owner: ->(controller, model) { controller && controller.current_user }

  acts_as_taggable_on :genre, :is_type

  belongs_to :user
  belongs_to :meta, polymorphic: true
  belongs_to :client, :class_name => 'Client', :foreign_key => :user_id
  belongs_to :filmmaker
  has_many :direct_hire_proposals
  has_many :milestones
  has_many :likes, :as => :loveable, :dependent => :destroy
  has_many :roles, :dependent => :destroy
  has_many :applications, :through => :roles
  has_many :fans, :through => :likes, :source => :user
  has_many :photos, :as => :imageable, :dependent => :destroy
  has_many :videos, :as => :videoable, :dependent => :destroy
  has_many :comments, :as => :commentable, :dependent => :destroy
  has_many :project_dates, :class_name => 'ImportantDate', :as => :important_dateable, :dependent => :destroy
  has_many :project_questions, :dependent => :destroy
  has_many :project_attachments, :dependent => :destroy
  has_many :project_blacklists, :dependent => :destroy
  has_many :project_proposals, :foreign_key => 'project_id', :class_name => 'ProjectProposal', :dependent => :destroy
	has_many :project_feedbacks, :class_name => 'ProjectFeedback', :foreign_key => :project_id, :dependent => :destroy

  serialize :skills, Array

  attr_accessible :title, :description, :start, :end, :featured, :roles_attributes,
                  :photos_attributes, :videos_attributes, :status, :genre, :is_type, :genre_list, :is_type_list,
                  :description, :compensation, :location, :headline, :project_dates_attributes, :union, :url_name,
									:union_present, :skills,  :price, :ip_address, :user_id, :is_featured, :featured_payment_status, :project_questions_attributes, :project_attachments_attributes

  accepts_nested_attributes_for :roles, :photos, :videos, :project_dates, :genre, :project_questions, :project_attachments, :allow_destroy => true
  validates_presence_of :title, :message => "is required"  # :description  -- removed from getting validated because not in a design
  #validates_presence_of :user_id, :message => "is required"
  validates :price, numericality: { :greater_than_or_equal_to => 500 }

  validates :headline, :length => { :maximum => 224 }

  geocoded_by :location   # can also be an IP address
  after_validation :geocode          # auto-fetch coordinates

  before_save :update_url_name

  PROJECT_PARAMS = [:client_name,:description,:minimum,:maximum,:maximum,:location,:skills,:commercial,:crowdfunding,:web,:music,:event,:other,:film_pro]
  CHECK_FILTER_PARAMS = [:commercial,:crowdfunding,:web,:music,:event,:other,:film_pro,"1_day","3_days","5_days","7_days","10_days","30_sec","1_min","1_2_min","2_5_min","5_min"]

  after_create do |project|
    if project.present? && project.client.present? && project.client.email.present?
      ProjectMailer.delay.project_confirmation(project)
    end
  end

  def update_url_name
    if self.title_changed?

      new_title = truncate(self.title, :length => 20, :separator => ' ', :omission => '')
      # if the name is changed, convert to the url name
      self.url_name = new_title.gsub(/\s/,'-').gsub(/[^a-zA-Z0-9-]/, '').downcase

      if self.id.present?
        same_named_count = Project.where("lower(url_name) like lower(?) and id <> ? ",  "#{self.url_name}%", self.id).size
      else
        # check  and get size of if any other Projects having the same url_name
        same_named_count = Project.where("lower(url_name) like lower(?)", "#{self.url_name}%").size
      end

      if same_named_count > 0
        if self.id.present?
          # append the id after the url_name.
          self.url_name = self.url_name + "-#{self.id}"
        else
          total_entities = Project.last.id rescue 0
          self.url_name = self.url_name + "-#{total_entities.to_i + 1}"
        end
      end
    end

    self.skills = Array.new if self.skills.blank? || self.skills == "[]"
    if self.skills.is_a?(String)
      self.skills = self.skills.split(',').to_a
    end
  end


  scope :popular,
    select('projects.*, count(likes.id) AS fans_count').
    joins("left outer join likes on likes.loveable_id = projects.id AND likes.loveable_type = 'Project' ").
    group("projects.id").
    order("fans_count DESC")


  def is_funded?
    proposals = self.project_proposals.collect(&:id)
    if proposals.present?
      project_hires = ProjectHire.where('proposal_id IN (?)', proposals)
      return true if project_hires.present?
    end
  end

  def approved_user_applications
    applications.where(approved: true).map { |application| application.user }
  end

  def get_logo
    if !type.empty?
      return "../assets/project_logo/#{type}.jpg"
    else
      return "../assets/project_logo/default.jpg"
    end
  end

  def display_photo
    if photos.present?
      photos.first.image.url(:original)
    else
      # TODO: Change this to default project image.
      "/assets/actor.png"
    end
  end

  def display_medium
    if photos.present?
      photos.first.image.url(:medium)
    else
      # TODO: Change this to default project image.
      "/assets/actor.png"
    end
  end

  def display_large
    if photos.present?
      photos.first.image.url(:large)
    else
      # TODO: Change this to default project image.
      "/assets/actor.png"
    end
  end

  def display_regular
    if photos.present?
      photos.first.image.url(:regular)
    else
      # TODO: Change this to default project image.
      "/assets/actor.png"
    end
  end

  def display_thumb
    if photos.present?
      photos.first.image.url(:thumb)
    else
      # TODO: Change this to default project image.
      "/assets/actor.png"
    end
  end


  def roles_percent
    total = roles.size
    if total > 0
      ((filled_roles.size.to_f / total.to_f) * 10).to_i
    else
      10
    end
  end

  def open_roles
    # returns all open roles
    roles.where(:filled => false)
  end

  def filled_roles
    roles.where(:fillapp/models/profile.rbed => true)
  end

  def self.genres
    { 'Action' => 'Action', 'Adventure' => 'Adventure', 'Animation' => 'Animation', 'Biography' => 'Biography',
    'Comedy' => 'Comedy', 'Crime' => 'Crime', 'Documentary' => 'Documentary', 'Drama' => 'Drama', 'Family' => 'Family',
    'Fantasy' => 'Fantasy', 'Film-Noir' => 'Film-Noir', 'History' => 'History', 'Horror' => 'Horror', 'Musical' => 'Musical',
    'Mystery' => 'Mystery', 'Romance' => 'Romance', 'Scifi' => 'Scifi', 'Sports' => 'Sports', 'Thriller' => 'Thriller',
    'War' => 'War', 'Western' => 'Western' }
  end

  def self.types
    {'Feature Length' => 'Feature Length', 'Explainer Video' => 'Explainer Video', 'Reality' => 'Reality', 'Short' => 'Short',
    'TV Series' => 'TV Series', 'Webisode' => 'Webisode'}
  end

  def self.status_stages
    { 'Draft' => 'Draft', 'Development' => 'Development', 'Pre-Production' => 'Pre-Production', 'Production' => 'Production', 'Post-Production' => 'Post-Production', 'Completed' => 'Completed'}
  end

  def self.compensation_stages
    {'Paid' => 'Paid', 'Low-Paid' => 'Low-Paid', 'Copy / Credit' => 'Copy / Credit'}
  end

  def self.unions
    {
      'Non-union' => 'Non-union',
      'SAG-AFTRA' => 'SAG-AFTRA',
      'WGA'       => 'WGA',
      'IATSE'     => 'IATSE',
      'PGA'       => 'PGA',
      'DGA'       => 'DGA',
      'Other'     => 'Other'
    }
  end

  def self.guilds
    unions
  end

  def roles_json
    super_roles = self.roles.group_by(&:name)
    roles_to_return = Hash.new

    super_roles.keys.each do |super_role|
      sub_roles = super_roles[super_role]
      roles_to_return[super_role] = {
        :subroles => sub_roles,
        :open_count => sub_roles.find_all{ |role| role.filled == false }.size,
        :filled_count => sub_roles.find_all{ |role| role.filled == true }.size,
        :total_count => sub_roles.size
      }
    end

    roles_to_return
  end

  def liker_ids
    fans.map(&:id)
  end

  def roles_for_dashboard
    super_roles = self.roles.group_by(&:name)
    roles_to_return = []
    super_roles.keys.each_with_index do |super_role, index|
 pp/models/profile.rb     # sub_roles = roles.where(:name => super_role)
      sub_roles = super_roles[super_role]
      roles_to_return << {
        :id => index,
        :name => super_role,
        :subroles_json => sub_roles.to_json(:include => {
                                          :applications => {
                                            :include => {
                                              :user => {
                                                :methods => [
                                                  :talent_names
                                                ],
                                                :include => [
                                                  :followers,
                                                  :resume
                                                ]
                                              }
                                            }
                                          }
                                        }),
        :open_count => sub_roles.find_all{ |role| role.filled == false }.size,
        :filled_count => sub_roles.find_all{ |role| role.filled == true }.size,
        :total_count => sub_roles.size
      }
    end
    roles_to_return
  end

  def participant_mails
    applications.map(&:user).map(&:email).join(', ')
  end

  def selected_applicants_mails
    applications.joins(:user).where("role_applications.approved  = true").pluck('users.email').uniq
  end

  def non_selected_applicants_mails
    applications.joins(:user).where("role_applications.approved  = false").pluck('users.email').uniq
  end

  def pending_applications
    applications.where(:role_applications => { :approved => false }, :roles => { :filled => false })
  end

  def self.projects_by_followers(user)
    Project.where('projects.user_id in (?)', user.followers.pluck('friendships.user_id'))
  end

  def self.projects_by_friends(user)
    Project.where('projects.user_id in (?)', user.friends.pluck('friendships.friend_id'))
  end

  def self.featured_projects
    Project.where(:featured => true)
  end

  def self.popular_projects
    Project.popular
  end

  def self.recently_launched
    Project.where('status <> ?', 'Draft').order('created_at DESC')
  end

  def self.recent_projects(page = nil, per_page = 10)
    Kaminari.paginate_array(recently_launched).per_page_kaminari(page).per(per_page)
  end

  def self.order_by_new(projects)
    projects.sort_by(&:created_at)
  end

  def self.order_by_popularity(projects)
    projects.sort_by{ |project|
      project.fans.size
    }.reverse
  end

  def self.order_by_featured(projects)
    projects.sort_by{ |project|
      project.featured ? 0 : 1
    }
  end

  def self.sample_featured_projects
    Project.where(featured: true)
    # featured_projects.first(10)
  end

  def self.sample_popular_projects
    popular_projects.where('status <> ?', 'Draft').first(3)
  end

  def super_roles_needed
    roles.pluck("DISTINCT name")
  end

  def is_complete_with_filmmaker?(filmmaker)
     return false if project_proposals.empty? || project_proposals.where("filmmaker_id = #{filmmaker.id}").empty? ||project_proposals.where("filmmaker_id = #{filmmaker.id}").first.project_proposal_milestones.empty?
     project_proposals.where("filmmaker_id = #{filmmaker.id}").first.project_proposal_milestones.where("is_complete is false").empty?
  end

  def is_complete_with_client?(client)
     return false if project_proposals.empty? || project_proposals.first.project_proposal_milestones.empty?
     project_proposals.first.project_proposal_milestones.where("is_complete is false").empty?
  end

  def self.search_all(projects, query, roles, sub_roles, cast_hash, genres, types, location, radius, order_by, page, per_page = nil)

    projects = Project.where('status <> ?', 'Draft') if (projects.nil? || projects.empty?)

    if query.present?
      projects = projects.where('lower(projects.title) like lower(?)', "%#{query}%")
    end

    query_string = ''

    if roles.present? and sub_roles.present?
      roles = [roles].flatten

      roles_with_sub_talents = sub_roles.keys

      roles_with_out_sub_talents = roles - roles_with_sub_talents

      # this needs to be handled in the cash_hash check loop
      roles = roles_with_out_sub_talents

      if cast_hash.present?
        # cast role is handled in cast_hash check loop
        roles_with_out_sub_talents = roles_with_out_sub_talents - ['Cast']
      end

      if roles_with_out_sub_talents.present?
        query_string = "( roles.name in #{roles_with_out_sub_talents.sql_array_for_in} ) OR "
      end

      query_string = query_string + roles_with_sub_talents.collect { |super_role|
        sub_roles[super_role] = [sub_roles[super_role]] if !sub_roles[super_role].kind_of?(Array)

        "( roles.name = '#{super_role}' AND roles.subrole in #{sub_roles[super_role].sql_array_for_in} )"

      }.join(' OR ')

      # projects = projects.joins(:roles).where(query_string).uniq

    elsif roles.present? and !cast_hash.present?
      roles = [roles].flatten

      query_string = "( roles.name IN #{roles.sql_array_for_in} )"

      # projects = projects.joins(:roles).where(:roles => {:name => roles}).uniq
    end

    # this will run every time when cast hash is present
    if cast_hash.present?
      roles = [roles].flatten

      # search for those projects containing roles in all other than Cast
      # and then search for projects containing role as cast and the cast hash params
      roles = roles - ['Cast']

      if query_string.present?
        query_string = query_string + " OR "
      end

      if roles.present?
        query_string = query_string + "( roles.name IN #{roles.sql_array_for_in} ) OR "
      end

      # example = if searched for  height => ['tall', 'short'], ethnicity => ['Asian', 'East Indian']
      # the following logic will search for the projects having (height as either of ['tall', 'short']) AND (ethnicity as either of ['Asian', 'East Indian'])
      query_string = query_string + cast_hash.collect { |key, value|
        val = value.kind_of?(Array) ? value : [value]
        "( roles.#{key.to_s} IN #{val.sql_array_for_in} )"
      }.join(' AND ')

    end

    # if above two if loops execute, they generate a query string.
    if query_string.present?
      projects = projects.joins(:roles).where(query_string).uniq

      # debugger
    end

    if genres.present?
      # if in case genres is a string tis would help to convert it to array
      # or if it is array, it will flatten.
      genres = [genres].flatten
      projects = projects.tagged_with(genres, :on => :genre)
    end

    if types.present?
      types = [types].flatten
      projects = projects.tagged_with(types, :on => :is_type)
    end

    if location.present?
      radius = 100 if radius.nil?
      projects = projects.near(location, radius)
    end

    if order_by.present?
      case order_by
      when 'recent'
        projects = projects.order('created_at DESC')
      when 'featured'
        projects = projects.order('featured DESC')
      when 'popular'
        projects =  projects.joins("left outer join likes on likes.loveable_id = projects.id AND likes.loveable_type = 'Project' ").
                    group("projects.id").
                    select('projects.*, count(likes.id) AS likes_count').
                    order("count(likes.id) DESC")
      end
    end



    Kaminari.paginate_array( projects ).per_page_kaminari(page).per(per_page)
  end

  def self.tested
    projects = Project.where('projects.id > 0')
    projects.joins("left outer join likes on likes.loveable_id = projects.id AND likes.loveable_type = 'Project' ").
                    group("projects.id").
                    select('projects.*, count(likes.id) AS likes_count').
                    order("count(likes.id) DESC")
  end

  def as_json(options = {})
    json = super(options)
    if options[:check_user].present?
      # tells if the user is following particular project
      json[:user_following] = self.liker_ids.include?(options[:check_user].id)
      json[:user_liked] = json[:user_following]
    end
    if options[:votes_data_for_user].present?
      user = options[:votes_data_for_user]
      json[:voted_by_user] = voted_by_user?(user)
      json[:voted_type_by_user] = voted_type_by_user(user)
    end

    if options[:for_search].present? and options[:for_search] == true
      json[:thumbnail] = display_thumb
      json[:label] = title
      json[:value] = title
      json[:category]= 'Projects'
      json[:url] = "/projects/#{id}"
    end

    if options[:include_fans].present? and options[:include_fans] == true
      json[:fans] = fans
    end

    if options[:comments_count].present? and options[:comments_count] == true
      json[:comments_count] = comments.count
    end

    if options[:fans_count].present? and options[:fans_count] == true
      json[:fans_count] = fans.count
    end

    json[:url_param] = url_param
    json[:display_photo] = display_photo
    json[:display_medium] = display_medium
    json[:display_regular] = display_regular
    json
  end

  def self.custom_json(projects, user = nil, comments_count = true, include_fans = true, fans_count = false)
    projects.to_json(:include => [
                        :photos,
                        :user
                      ],
                      :methods => [
                        :super_roles_needed,
                        :roles_percent,
                        :open_roles,
                        :liker_ids,
                        :display_photo
                      ],
                      :check_user => user,
                      :include_fans => include_fans,
                      :fans_count => fans_count,
                      :comments_count => comments_count
                    )
  end

  def similar_events
    Event.near(location) + self.user.events
  end

  def similar_projects
    self.nearbys
  end

  def display_photo_big
    if photos.present?
      photos.first.image.url
    else
      "/assets/actor.png"
    end
  end

  def self.search_projects(query)
    Project.where('lower(title) like lower(?) or lower(description) like lower(?)', "%#{query}%", "%#{query}%")
  end

  def valid_videos
    videos.where('provider IS NOT NULL')
  end

  def display_dates
    project_dates.order("important_dates.date_time ASC")
  end

  def self.role_types
    {
      'Agent'                                             => 'Agent',
      'Art Department'                                    => 'Art Dept',
      'Business - Manager, Studio Exec'                   => 'Business',
      'Cast - Actor'                                      => 'Cast',
      'Camera Dept.'                                      => 'Camera',
      'Directing'                                         => 'Directing',
      'Hair - Make Up'                                    => 'Hair - Make Up',
      'Light Dept.'                                       => 'Light',
      'Pre Production - Casting Director, Location'       => 'Pre-Production',
      'Production - Producer, Assistant'                  => 'Production',
      'Post-Pro - Editor, Effects'                        => 'Post-Pro',
      'Set - Hair, Makeup, Construction'                  => 'Set',
      'Sound/Audio Dept.'                                 => 'Sound',
      'Wardrobe'                                          => 'Wardrobe',
      'Writing Department - Screenwriter, Assistant etc.' => 'Writer',
      'Other'                                             => 'Other'
    }
  end

  def self.role_sub_types
    {
      'Cast'           => {
                            "Background"       => "Background",
                            "Co star"          => "Co star",
                            "Dancer"           => "Dancer",
                            "Extra"            => "Extra",
                            "Feature"          => "Feature",
                            "Guest-star"       => "Guest-star",
                            "Lead"             => "Lead",
                            "Other"            => "Other",
                            "Principal"        => "Principal",
                            "Precision driver" => "Precision driver",
                            "Special"          => "special",
                            "Stand-in"         => "stand-in",
                            "Stunt"            => "stunt",
                            "Supporting"       => "supporting",
                            "Double"           => "double",
                            "Voice"            => "Voice"
                          },
        'Camera'          => {
                              'Director of Photography (DP)' => 'Director of Photography (DP)',
                              'Camera Operator'              => 'Camera Operator',
                              'Camera Assistant'             => 'Camera Assistant',
                              'B Camera Operator'            => 'B Camera Operator',
                              '2nd Unit Cinematographer.'    => '2nd Unit Cinematographer.',
                              'Additional Cinematography'    => 'Additional Cinematography',
                              'Still Photographer'           => 'Still Photographer',
                              'DIT (Digital Imaging Tech)'   => 'DIT (Digital Imaging Tech)',
                              'Steadicam operator'           => 'Steadicam operator',
                              'Underwater DP'                => 'Underwater DP'
                            },
        'Light'           => {
                              'Best Boy'    => 'Best Boy',
                              'Electrician' => 'Electrician',
                              'Gaffer'      => 'Gaffer',
                              'Grip'        => 'Grip',
                              'Key Grip'    => 'Key Grip'
                            },
        'Sound'            => {
                              'Composer'         => 'Composer',
                              'Sound Designer'   => 'Sound Designer',
                              'Sound Technician' => 'Sound Technician',
                              'Boom operators'   => 'Boom operators',
                              'Sound assistants' => 'Sound assistants',
                              'Dialogue editor'  => 'Dialogue editor',
                              'Dubbing mixer'    => 'Dubbing mixer',
                              'Foley artist'     => 'Foley artist',
                              'Foley editor'     => 'Foley editor',
                              'Production mixer' => 'Production mixer',
                              'Sound editor'     => 'Sound editor',
                              'Sound recordist'  => 'Sound recordist'
                            },
        'Set'            => {
                              "Make up artist"        => "Make up artist",
                              "Hairdresser"           => "Hairdresser",
                              "Costume"               => "Costume",
                              "Costume Assistant"     => "Costume Assistant",
                              "Prop builder"          => "Prop builder",
                              "Prop assistant"        => "Prop assistant",
                              "Set decorator/dresser" => "Set decorator/dresser",
                              "Script Supervisor"     => "Script Supervisor",
                            },
        'Production'     => {
                              "Production Assistant"              => "Production Assistant",
                              "Production Accountant/Asst"        => "Production Accountant/Asst",
                              "Producer"                          => "Producer",
                              "Production Supervisor/Coordinator" => "Production Supervisor/Coordinator",
                              "Exec. Producer"                    => "Exec. Producer",
                              "Line Producer"                     => "Line Producer"
                            },
        'Post-Pro'       => {
                              "Editor"                      => "Editor",
                              "Editor asst"                 => "Editor asst",
                              "Visual effects"              => "Visual effects",
                              "Graphic/Titles design"       => "Graphic/Titles design",
                              "Post- production Supervisor" => "Post- production Supervisor"
                            },
        'Business'       => {
                              "Manager"          => "Manager",
                              "Lawyer"           => "Lawyer",
                              "Studio Executive" => "Studio Executive",
                              "Investment"       => "Investment",
                              "Marketing / PR"   => "Marketing/PR",
                              "Distribution"     => "Distribution"
                            },
        'Writer'         => {
                              "Screenwriter"        => "Screenwriter",
                              "Script Consultant"   => "Script Consultant",
                              "Script Coordinators" => "Script Coordinators",
                              "Writers' Assistants" => "Writers' Assistants",
                              "Formatter/Proofer"   => "Formatter/Proofer"
                            },
        'Pre-Production' => {
                              "Location Scout"     => "Location Scout",
                              "Location Manager"   => "Location Manager",
                              "Location Assistant" => "Location Assistant",
                              "Casting Director"   => "Casting Director",
                              "Casting Assistant"  => "Casting Assistant"
                            },
        'Directing'       => {
                              "Director"       => "Director",
                              "Asst. Director" => "Asst. Director"
                            },
        'Agent'          => {},
        'Other'          => {
                              "Food / Catering"    => "Food/Catering",
                              "Acting Coach"       => "Acting Coach",
                              "Security"           => "Security",
                              "Medic"              => "Medic",
                              "Stunt coordinator"  => "Stunt coordinator",
                              "Pyrotechnics"       => "Pyrotechnics",
                              "Aerial photography" => "Aerial photography",
                              "Intern"             => "Intern",
                              "Personal Assistant" => "Personal Assistant",
                              "PR Executive"       => "PR Executive",
                              "Other"              => "Other"
                            },
          'Hair - Make Up' => {
                              "Make up Artist"                          => "Make up Artist",
                              "Make up Assistant"                       => "Make up Assistant",
                              "Prosthetics/Special Effects Artist"      => "Prosthetics/Special Effects Artist",
                              "Hair Stylist"                            => "Hair Stylist",
                          		"Hair Assistant"                          => "Hair Assistant"
                            },
          'Wardrobe' => {
                              "Costume Designer"    => "Costume Designer",
                              "Costume Assistant"   => "Costume Assistant",
                              "Costume Supervisor"  =>  "Costume Supervisor",
                              "Seamstress"          =>  "Seamstress",
                              "Costume buyer"       =>  "Costume buyer"
                            },
          'Art Dept'  =>  {
                              "Production Designer"     =>  "Production Designer",
                              "Art Director"            =>  "Art Director",
                              "Assistant Art Director"  =>  "Assistant Art Director",
                              "Storyboard Artist"       =>  "Storyboard Artist",
                              "Draftsman"               =>  "Draftsman",
                              "Set Decorator"           =>  "Set Decorator",
                              "Set Dresser"             =>  "Set Dresser",
                              "Property Master"         =>  "Property Master",
                              "Leadman"                 =>  "Leadman",
                              "Swing Gang"              =>  "Swing Gang",
                              "Production Buyer"        =>  "Production Buyer",
                              "Property Assistant"      =>  "Property Assistant"
                            },
      }
  end

  def self.role_super_sub_types
    { }
  end

  def url_param
    url_name.present? ? url_name : id
  end

   def managers
    # Users who has a role application that is applied to the roles in this project and is approved as well as has the manager set true
    User.joins( :role_applications => :role ).
    where( "role_applications.approved = true AND role_applications.manager = true AND roles.project_id = ? ", self.id ).
    uniq
  end

  def is_manager?( user )
    managers.include?( user )
  end

  # returns project client name
  def client_name
    self.client.name if self.present? && self.client.present?
  end

  def pro_client
    if self.present? && self.client.present?
      self.client.pro_account ? true : false
    end
  end

	def self.exclude_blacklisted_projects filmmaker
    blacklisted_projects = filmmaker.project_blacklists
    #filmmaker_projects = filmmaker.own_projects.collect(&:id)
    dr_projects = DirectHire.all_direct_hire_projects
    query = "user_id is not null"
    query += " AND id NOT IN (#{dr_projects.join(",")})" unless dr_projects.blank?
    projects = Project.where(query).all
    return projects unless blacklisted_projects.any?
    blacklist = blacklisted_projects.pluck(:project_id)
    projects = projects.reject{|project| project if project.id.in?(blacklist)}
    projects
  end

	 def project_details
    questions = ['About how long do you want it to be?', "Proposals due by", "Who do you want applicants by?"]
    project_detail(questions)
  end

	 def project_full_details
    questions = ["Do you need any actors?", "Do you need music?", "Do you have an idea for a script?", "What style of video do you want?", "Who do you want applicants by?", "Proposals due by", "About how long do you want it to be?"]
    project_detail(questions)
  end

	 def project_details_list
    questions_list = ["What type of video do you want?", "What style of video do you want?", "Do you have an idea for a script?", "Do you need any actors?", "Do you need music?", "About how long do you want it to be?", "Proposals due by", "Who do you want applicants by?"]
    project_ques_details(questions_list)
  end

	 def client_details
    details = {}
    client = self.client
		details[:id] = client.id
    details[:name] = client.name
    details[:proposal_due_in] = ((((self.created_at + self.project_details.second.split(" ").first.to_i.days) - Time.now).to_i) / 3600 ) rescue 0
    if details[:proposal_due_in] < 0
      details[:proposal_due_in] = 'Closed'
    else
      if details[:proposal_due_in] > 23
        details[:proposal_due_in] = (details[:proposal_due_in]/24).to_s+' Days'
      else
        details[:proposal_due_in] = details[:proposal_due_in].to_s+' Hours'
      end
    end
    details[:budget] = number_to_currency(self.price.round.to_s, precision: 0) rescue 0
    details
  end

	 def filmmaker_details filmmaker_id
    filmmaker = Filmmaker.find(filmmaker_id)
    details = {}
    # details[:id] = filmmaker.id
    details[:name] = filmmaker.name
    details[:desired_rate] = filmmaker.rate
    details[:location] = filmmaker.location
    details[:skills] = filmmaker.skills
    details[:rating] = filmmaker.filmmaker_feedbacks.any? ? filmmaker.filmmaker_feedbacks.average(:rating) : 0
    details[:awarded_projects] = filmmaker.project_proposals.where("is_approved = ?",true).collect(&:project).count
    details
  end

	 def new_proposal_details filmmaker_id
    details = {}
    details[:name] = self.title
    details[:filmmaker_details] = self.filmmaker_details filmmaker_id
    return details
  end

	 def self.create_new_project parameters, ip_address, client=nil
    project_id = 0
    project_parameters = {}
    skills = parameters['skills']
    if skills.present? && skills.is_a?(String)
      skills = skills.split(',').to_a
    else
      skills = []
    end
    project_parameters.merge!(:title => parameters['project']['title'],
    :description => parameters['project']['description'],
    :skills => skills,
    :price => parameters['price'].to_f,
    :location => parameters['project']['location'],
    :ip_address => ip_address,
    :is_featured => parameters[:is_featured])

    unless client.nil?
    project = client.projects.new(project_parameters)
    else
      project = Project.new(project_parameters)
    end

    if project.save

      project.project_attachments.create(:attachment => parameters['project_attachment']) if parameters['project_attachment'].present?


      (1..8).to_a.each do |num|
        project.project_questions.create(:question_text => parameters["question_#{num.to_s}"],
        :answer_text   => parameters["answer_#{num.to_s}"]) if parameters["question_#{num.to_s}"].present?
      end
    project_id = project.id
    else
      p project.errors.inspect
    end
    return project_id
  end

  def active_proposals
    project_proposals.where(:is_delete => false).order("created_at desc")
  end

  def project_proposal_details(proposals=[])
    result_data = []
    pro_proposals = proposals.empty? ? active_proposals : proposals
    pro_proposals.each do |proposal|
      proposal_details = {}
      filmmaker = proposal.filmmaker
      is_pro = false
      is_pro = filmmaker.is_pro? if filmmaker.present?
      fm_rating = filmmaker.filmmaker_feedbacks.any? ? number_with_precision(filmmaker.filmmaker_feedbacks.average(:rating), :precision => 1) : 0.0
      demo_reel = filmmaker.demo_reel
      resumes_present = !(proposal.proposal_resumes.blank?)
      filmmaker_details = {:id => filmmaker.id, :name => filmmaker.name, :location => filmmaker.location, :skills => filmmaker.skills, :rating => fm_rating, :reel_url => demo_reel.try(:embed_code), :reel_image => demo_reel.try(:thumbnail_large), :resumes_present => resumes_present, :is_filmmaker_hired => filmmaker.hired_in_project(proposal), :profile_image => filmmaker.profile_photo, :is_pro => is_pro, :project_as_hire => self.as_hire?}
      milestone_details = {:cover_letter => proposal.cover_letter}
      milestone_data = []
      proposal.project_proposal_milestones.each{|m| milestone_data << {:name => m.name, :delivery_date => m.delivery_date, :amount => m.amount.to_i } }
      milestone_details[:milestones] = milestone_data
      milestone_details[:total] = proposal.project_proposal_milestones.sum(:amount).to_i
      proposal_details[:proposal] = {:proposal_id => proposal.id, :filmmaker_details => filmmaker_details, :milestone_details => milestone_details}
      result_data << proposal_details
    end
    return result_data
  end

  def is_filmmaker_working_in_project?
    is_working  = false
    proposals = self.project_proposals
    if proposals != []
      hire = ProjectHire.where(:proposal_id => self.project_proposals.pluck(:id)).first
      if hire
	hired_for_proposal = ProjectProposal.find(hire.proposal_id)
	project_running = hired_for_proposal.project_proposal_milestones.where(:payment_released => false).any?
	is_working = !project_running
      end
    end
    is_working
  end

  def is_filmmaker_working_in_direct_hire_project?
    is_working  = false
    proposals = self.direct_hire_proposals
    if proposals != []
      hire = ProjectDirectHire.where(:direct_hire_proposal_id => self.direct_hire_proposals.pluck(:id)).first
      if hire
        hired_for_proposal = DirectHireProposal.find(hire.direct_hire_proposal_id)
        project_running = hired_for_proposal.direct_hire_proposal_milestones.where(:payment_released => false).any?
        is_working = !project_running
      end
    end
    is_working
  end

  def is_complete?
    is_complete = false
    proposals = self.project_proposals
    if proposals != []
      hire = ProjectHire.where(:proposal_id => self.project_proposals.pluck(:id)).first
      if hire
        first_proposal = self.project_proposals.first if self.project_proposals.present?
        proposal_revision = ProposalRevision.where(project_proposal_id: first_proposal.id).last if first_proposal.present?
        if proposal_revision.present?
          project_running = proposal_revision.updated_project_proposal_milestones.where(:payment_released => false).any?
          is_complete = true if !project_running
        else
          hired_for_proposal = ProjectProposal.find(hire.proposal_id)
  	      project_running = hired_for_proposal.project_proposal_milestones.where(:payment_released => false).any?
  	      is_complete = true if !project_running
        end
      end
    end
    is_complete
  end

  def is_direct_hire_project_complete?
    is_complete = false
    proposals = self.direct_hire_proposals
    if proposals != []
      hire = ProjectDirectHire.where(:direct_hire_proposal_id => proposals.pluck(:id)).first
      if hire
        hired_for_proposal = DirectHireProposal.find(hire.direct_hire_proposal_id)
        project_running = hired_for_proposal.direct_hire_proposal_milestones.where(:payment_released => false).any?
        is_complete = true if !project_running
      end
    end
    is_complete
  end

  def proposal_due_time
    days_ans = self.project_questions.find_by_question_text("Proposals due by").answer_text.split(" ").first rescue 0
    end_date = self.created_at.utc + days_ans.to_i.days
    rem_days = end_date - Time.now.utc
  end

  def proposal_due_days
    rem_days = ((proposal_due_time / 3600) / 24).to_i
    rem_days
  end

  def updated_proposal_due_days
    rem_days = proposal_due_time
    rem_days
  end

  def proposal_due_hours
   # proposal_due_in = ((((self.created_at + self.project_details.second.split(" ").first.to_i.days) - Time.now).to_i) / 3600 ) rescue 0
   # proposal_due_in = proposal_due_in.to_s +'h'
     rem_time = proposal_due_time
     hours = rem_time / 3600
     hours.to_i
  end

  def proposal_new?
    if ((Time.now - self.created_at) / 3600) <= 24
      return true
    else
      return false
    end
  end

  def project_status
    proposal_due_in = ((((self.created_at + self.project_details.second.split(" ").first.to_i.days) - Time.now).to_i) / 3600 ) rescue 0
    if proposal_due_in < 0
      proposal_due_in = 'Closed'
    else
      if proposal_due_in > 23
        proposal_due_in = (proposal_due_in/24).to_s+'d left'
      else
        proposal_due_in = proposal_due_in.to_s+'h left'
      end
    end
    proposal_due_in
  end

  def as_hire?
    hire = false
    proposals = self.project_proposals
    unless proposals.empty?
      hire = !(ProjectHire.where(:proposal_id => self.project_proposals.pluck(:id)).first.blank?)
    end
    hire
  end

  def skills_list_pub
    if self.skills.present?
      #self.skills.split(',').collect(&:strip)
      self.skills
    else
      Array.new
    end
  end

private
  def project_detail(questions)
  	  result = Array.new
  	  answers = self.project_questions.where("question_text in (?)", questions).order('id asc')
  	      unless answers.empty?
  		    result << answers.pluck(:answer_text)
  	      end
  	  result.flatten
  end

  def project_ques_details(questions)
	  result = []
	  answers = self.project_questions.where("question_text in (?)", questions).order('id asc')
		result << answers.try(:pluck, :answer_text)
	  result.flatten
  end

  def skills_list
    if @project.skills.present?
      @project.skills.split(',').collect(&:strip)
    else
      ["No Skills Entered"]
    end
  end
end

class Array
  def sql_array_for_in
    self.to_s.gsub(/]/, ')').gsub(/\[/, '(').gsub(/"/,'\'')
  end
end
