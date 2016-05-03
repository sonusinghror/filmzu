class AdminUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :balanced_uri, :default_account, :default_account_type,
                  :default_backup_account, :default_backup_account_type,
                  :first_name, :last_name

  has_many :bank_accounts, :as => :bank_accountable
  has_many :withdraws, as: :withdrawable

  def self.admin_dashboard_entries
    AdminUser.order('created_at DESC').limit(5)
  end

  def name
    "#{self.first_name} #{self.last_name}"
  end
end
