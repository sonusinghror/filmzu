ActiveAdmin.register Client do
  index do
    column :name
    column :email
    column :location
    column :balance do |client|
      number_to_currency client.balance, :unit => "$"
    end
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    column :created_at
    default_actions
  end

  filter :name
  filter :email

  form do |f|
    f.inputs 'Client Details' do
      f.input :name
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :location
    end
    f.actions
  end

  controller do
    def update
      if params[:client][:password].blank? && params[:client][:password_confirmation].blank?
        params[:client].delete("password")
        params[:client].delete("password_confirmation")
      end
      super
    end
  end
end
