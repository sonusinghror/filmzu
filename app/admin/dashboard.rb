ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do
    #div :class => "blank_slate_container", :id => "dashboard_default_message" do
    #  span :class => "blank_slate" do
    #    span I18n.t("active_admin.dashboard_welcome.welcome")
    #    small I18n.t("active_admin.dashboard_welcome.call_to_action")
    #  end
    #end

    # Here is an example of a simple dashboard with columns and panels.
    #
    #First Row
    columns do
      column do
        panel "Recent Deposits" do
          table_for Deposit.order('created_at DESC').limit(5) do
            column('Deposited by'){|d| link_to "#{d.depositable.name rescue nil}", "#{d.depositor_uri rescue nil}" }
            column('Transaction Number'){|d| link_to d.transaction_number, admin_deposit_path(d) }
            column('Amount'){|d| link_to "$#{d.amount.to_i/100}", admin_deposit_path(d) }
            column('Status'){|d| d.status }
            column('View'){|d| link_to 'View', admin_deposit_path(d) }
          end
        end
      end

      column do
        panel "Recent Withdrawals" do
          table_for Withdraw.order('created_at DESC').limit(5) do
            column('Withdrawn by'){|w| link_to "#{w.withdrawable.name rescue nil}", "#{w.withdrawer_uri rescue nil}" }
            column('Transaction Number'){|w| link_to w.transaction_number, admin_withdraw_path(w) }
            column('Amount'){|w| link_to "$#{w.amount.to_f/100}", admin_withdraw_path(w) }
            column('Status'){|w| w.status }
            column('View'){|w| link_to 'View', admin_withdraw_path(w) }
          end
        end
      end
    end

    #Second Row
    columns do
      column do
        panel "Recent Filmmakers" do
          table_for Filmmaker.admin_dashboard_entries do
            column('Name'){|fm| link_to fm.name, admin_filmmaker_path(fm) }
            column('Email'){|fm| link_to fm.email, admin_filmmaker_path(fm) }
            column('Rate'){|fm| "#{'$' + fm.rate.to_s if fm.rate.present?}" }
            column('Location'){|fm| fm.location }
            column('View'){|fm| link_to 'View', admin_filmmaker_path(fm) }
          end
        end
      end

      column do
        panel "Recent Clients" do
          table_for Client.admin_dashboard_entries do
            column('Name'){|client| link_to client.name, admin_client_path(client) }
            column('Email'){|client| link_to client.email, admin_client_path(client) }
            column('Location'){|client| client.location }
            column('View'){|client| link_to 'View', admin_client_path(client) }
          end
        end
      end
    end

    #Third Row
    columns do
      column do
        panel "Recent Projects" do
          table_for Project.order('created_at DESC').limit(5) do
            column('Title'){|prj| link_to prj.title, admin_project_path(prj) }
            column('Posted by'){|prj| link_to prj.client.name, admin_client_path(prj.user_id) rescue nil }
            column('Budget'){|prj| "#{ '$' + prj.price.to_s if prj.price.present? }" }
            column('Location'){|prj| prj.location }
            column('View'){|prj| link_to 'View', admin_project_path(prj) }
          end
        end
      end

      column do
        panel "Recent Admin Users" do
          table_for AdminUser.admin_dashboard_entries do
            column('Email'){|admin| link_to admin.email, admin_admin_user_path(admin) }
            column('View'){|admin| link_to 'View', admin_admin_user_path(admin) }
          end
        end
      end
    end

  end
end
