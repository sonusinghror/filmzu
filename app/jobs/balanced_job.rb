# This class includes asynchronous operations
# to be performed for balanced payments
#
# Filename      : balanced_job.rb
# Creation Date : 02-07-2014

class BalancedJob
  include SuckerPunch::Job
  
  def create_marketplace_customer(customer_record)
    puts ">>>>>>>>>>>>>> begin marketplace customer job"
    uri = get_marketplace_customer_uri(customer_record.name, customer_record.email)
    customer_record.update_attributes(:balanced_uri => uri) if uri != ''
    puts "<<<<<<<<<<<<<< end marketplace customer job"
  end
  
  
  private
  
  def get_marketplace_customer_uri(customer_name, customer_email)
    result = ''
    customer_details = {
                         :email => customer_email,
                         :name  => customer_name
                       }
    begin
      balanced_response = Balanced::Marketplace.my_marketplace.customers.create(customer_details)
      result = balanced_response.attributes['href']
    rescue => e
      puts e.inspect  
    end 
    return result
  end
  
  
  
end