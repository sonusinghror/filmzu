require 'rufus-scheduler'

s = Rufus::Scheduler.singleton
s.every '1d' do
  ProAccount.renew_pro_accounts
end
