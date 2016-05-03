class AddFeaturedPaymentStatusToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :featured_payment_status, :boolean, :default => false
  end
end
