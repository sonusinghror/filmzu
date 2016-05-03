ActiveAdmin.register Filmmaker do
  index do
    column :name
    column :email
    column :rate do |filmmaker|
      "#{'$' + filmmaker.rate.to_s if filmmaker.rate.present?}"
    end
    column :location
    column :company
    column :balance do |filmmaker|
      number_to_currency filmmaker.balance, :unit => "$"
    end
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    column :created_at
    default_actions
  end

  filter :name
  filter :email

  form :partial => 'form'

=begin
  form do |f|
    f.inputs 'Filmmaker Details' do
      f.input :name
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :verified
      f.input :verified_by_admin
      f.input :about
      f.input :location
      f.input :skills
      f.input :rate
      f.input :is_company
      f.input :company
    end
    f.actions
  end
=end

  controller do
    def update
      if params[:filmmaker][:password].blank? && params[:filmmaker][:password_confirmation].blank?
        params[:filmmaker].delete("password")
        params[:filmmaker].delete("password_confirmation")
      end
      super
    end
  end
end
