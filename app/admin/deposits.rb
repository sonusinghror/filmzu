ActiveAdmin.register Deposit do
  index do
    column :depositable_id do |deposit|
      deposit.depositor_name
    end
    column :transaction_number
    column :amount do |deposit|
      "#{'$' + (deposit.amount.to_i/100).to_s if deposit.amount.present? }"
    end
    column :balanced_created_at
    column :failure_reason
    column :failure_reason_code
    column :balanced_id
    column :status
    column :created_at
    column :pro
    default_actions
  end

  show do |deposit|
    attributes_table do
      columns_to_exclude = ["amount"]
      (Deposit.column_names - columns_to_exclude).each_with_index do |c, index|
        row c.to_sym
        if index == 2
          row :amount do
            "#{ '$' + (deposit.amount.to_f/100).to_s if deposit.amount.present? }"
          end
        end
      end
    end
  end

  form do |f|
    f.inputs "Deposit Details" do
      f.input :depositable_client, collection: Client.all, label: "Select Client (if client is adding fund)"
      f.input :depositable_filmmaker, collection: Filmmaker.all, label: "Select Filmmaker (if filmmaker is paying for Pro Account)"
      f.input :transaction_number
      f.input :amount
      f.input :currency, :input_html => { :value => 'USD', :readonly => true }
      f.input :failure_reason
      f.input :failure_reason_code
      f.input :balanced_id
      f.input :status
      f.input :pro, label: 'Is this a payment for Pro Account?'
    end
    f.actions
  end
end
