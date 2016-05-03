class Withdraw < ActiveRecord::Base
  before_validation :assign_withdrawable
  belongs_to :withdrawable, polymorphic: true
  attr_accessible :amount, :appears_on_statement_as, :balanced_created_at,
                  :currency, :description, :failure_reason,
                  :failure_reason_code, :href, :balanced_id,
                  :link_customer, :link_destination, :status,
                  :transaction_number, :balanced_updated_at,
                  :withdrawable_client, :withdrawable_filmmaker

  attr_accessor :withdrawable_filmmaker,  :withdrawable_client

  validates :withdrawable_id, :withdrawable_type, :amount, :currency,
            :transaction_number, presence: true
            
  def withdrawable_filmmaker
    self.withdrawable.id if self.withdrawable.is_a? Filmmaker
  end

  def withdrawable_client
    self.withdrawable.id if self.withdrawable.is_a? Client
  end

  def withdrawer_uri
    path = "/admin/#{self.withdrawable_type.downcase}s/#{self.withdrawable_id}"
    path
  end

  def withdrawer_name
    self.withdrawable.name rescue nil
  end

protected
  def assign_withdrawable
    if !@withdrawable_filmmaker.blank? && !@withdrawable_client.blank?
      errors.add(:withdrawable, "can't have both a filmmaker and a client")
    end

    unless @withdrawable_filmmaker.blank?
      self.withdrawable = Filmmaker.find(@withdrawable_filmmaker)
    end

    unless @withdrawable_client.blank?
      self.withdrawable = Client.find(@withdrawable_client)
    end
  end
end
