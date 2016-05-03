ActiveAdmin.register Withdraw do
  index do
    column :transaction_number
    column :withdrawable_id do |withdraw|
      withdraw.withdrawer_name
    end
    column :amount do |withdraw|
      "#{ '$' + (withdraw.amount.to_f/100).to_s if withdraw.amount.present? }"
    end
    column :balanced_created_at
    column :failure_reason
    column :failure_reason_code
    column :balanced_id
    column :status
    column :created_at
    default_actions
  end

  show do |withdraw|
    attributes_table do
      columns_to_exclude = ["amount"]
      (Withdraw.column_names - columns_to_exclude).each_with_index do |c, index|
        row c.to_sym
        if index == 2
          row :amount do
            "#{ '$' + (withdraw.amount.to_f/100).to_s if withdraw.amount.present? }"
          end
        end
      end
    end
  end

  form do |f|
    f.inputs "Withdraw Details" do
      f.input :withdrawable_client, collection: Client.all, label: "Select Client (if client is withdrawing fund)"
      f.input :withdrawable_filmmaker, collection: Filmmaker.all, label: "Select Filmmaker (if filmmaker is withdrawing fund)"
      f.input :transaction_number
      f.input :amount
      f.input :currency, :input_html => { :value => 'USD', :readonly => true }
      f.input :failure_reason
      f.input :failure_reason_code
      f.input :balanced_id
      f.input :status
    end
    f.actions
  end
end
