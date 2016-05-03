class Deposit < ActiveRecord::Base
  before_validation :assign_depositable
  belongs_to :depositable, polymorphic: true
  attr_accessible :amount, :appears_on_statement_as, :balanced_created_at,
                  :currency, :description, :failure_reason,
                  :failure_reason_code, :href, :balanced_id, :status,
                  :transaction_number, :balanced_updated_at, :link_card_hold,
                  :link_customer, :link_dispute, :link_order, :link_source,
                  :pro, :depositable_client, :depositable_filmmaker

  attr_accessor :depositable_filmmaker,  :depositable_client

  validates :depositable_id, :depositable_type, :amount, :currency,
            :transaction_number, presence: true

  def depositable_filmmaker
    self.depositable.id if self.depositable.is_a? Filmmaker
  end

  def depositable_client
    self.depositable.id if self.depositable.is_a? Client
  end

  def depositor_uri
    path = "/admin/#{self.depositable_type.downcase}s/#{self.depositable_id}"
    path
  end

  def depositor_name
    self.depositable.name rescue nil
  end

  def self.add_deposit(client, debit_hash)
    deposit_hash = {
      amount: debit_hash['amount'],
      appears_on_statement_as: debit_hash['appears_on_statement_as'],
      balanced_created_at: debit_hash['created_at'],
      currency: debit_hash['currency'],
      description: debit_hash['description'],
      failure_reason: debit_hash['failure_reason'],
      failure_reason_code: debit_hash['failure_reason_code'],
      href: debit_hash['href'],
      balanced_id: debit_hash['id'],
      status: debit_hash['status'],
      transaction_number: debit_hash['transaction_number'],
      balanced_updated_at: debit_hash['updated_at'],
      link_card_hold: debit_hash['links']['card_hold'],
      link_customer: debit_hash['links']['customer'],
      link_dispute: debit_hash['links']['dispute'],
      link_order: debit_hash['order'],
      link_source: debit_hash['source']
    }
    deposit = client.deposits.create(deposit_hash)
    deposit
  end

protected
  def assign_depositable
    if !@depositable_filmmaker.blank? && !@depositable_client.blank?
      errors.add(:depositable, "can't have both a filmmaker and a client")
    end

    unless @depositable_filmmaker.blank?
      self.depositable = Filmmaker.find(@depositable_filmmaker)
    end

    unless @depositable_client.blank?
      self.depositable = Client.find(@depositable_client)
    end
  end
end
