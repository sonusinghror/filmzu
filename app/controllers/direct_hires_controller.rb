class DirectHiresController < ApplicationController
  
  before_filter :authenticate_filmmaker!
  before_filter :find_proposal
  
  def accept_proposal
   if @proposal.update_attributes(:is_approved => true, :is_declined => false)
    DirectHire.hire_filmmaker @proposal
   end
   
    @response_data = {}
    client = Client.find(@proposal.client_id)
    
    client_details = {
      :name => client.name,
      :location => client.location,
      :sent_at => @proposal.created_at.strftime("%H:%M %P"),
      :image => client.profile_photo
    }
    
    if @proposal.desired_start_date && @proposal.desired_end_date
      proposal_details = {
        :dates => [@proposal.desired_start_date.strftime("%B %d, %Y %H:%M"), @proposal.desired_end_date.strftime("%B %d, %Y %H:%M")]
      }
    else
      proposal_details = {
        :dates => [nil,nil]
      }  
    end

    proposal_details.merge!(:cover_letter => @proposal.cover_letter)
    
    milestone_details = []
    total_project_amount = 0
    @proposal.direct_hire_proposal_milestones.each do |milestone|
      total_project_amount += milestone.amount.to_i 
      milestone_details << {:name => milestone.name, :delivery_date => milestone.delivery_date, :amount => milestone.amount.to_i}
    end
    
    @response_data[:filmmaker_details] = client_details
    @response_data[:proposal_details]  = proposal_details
    @response_data[:milestone_details] =  milestone_details
    @response_data[:total] = @proposal.direct_hire_proposal_milestones.sum(:amount).to_i
    
   basic_project_params = {"project"=>{"title"=>"Direct Hire Requested Project"}, "is_featured"=>"false", "price" => total_project_amount}
   proj_id = Project.create_new_project basic_project_params, request.remote_ip, client
   @proposal.update_attribute(:project_id, proj_id)
   
   respond_to do |format|
    format.js
    format.html { redirect_to :back }
   end
  end

  def prompt_decline_proposal
    client = Client.find(@proposal.client_id)
    @client_details = {:name => client.name,
                      :location => client.location,
                      :post => 'Camera Operator',
                      :rating => '5.0 Stars'
                      }
    render :layout => 'popup'
  end
  
  def decline_proposal
   @proposal.update_attributes(:is_declined => true, :is_approved => false)
   
   @response_data = {}
    client = Client.find(@proposal.client_id)
    
    client_details = {
      :name => client.name,
      :location => client.location,
      :sent_at => @proposal.created_at.strftime("%H:%M %P")
    }

    if @proposal.desired_start_date && @proposal.desired_end_date
      proposal_details = {
        :dates => [@proposal.desired_start_date.strftime("%B %d, %Y %H:%M"), @proposal.desired_end_date.strftime("%B %d, %Y %H:%M")]
      }
    else
      proposal_details = {
        :dates => [nil,nil]
      }    
    end  
    
    proposal_details.merge!(:cover_letter => @proposal.cover_letter)

    milestone_details = []
    @proposal.direct_hire_proposal_milestones.each do |milestone|
      milestone_details << {:name => milestone.name, :delivery_date => milestone.delivery_date, :amount => milestone.amount.to_i}
    end
    
    @response_data[:filmmaker_details] = client_details
    @response_data[:proposal_details]  = proposal_details
    @response_data[:milestone_details] =  milestone_details
    @response_data[:total] = @proposal.direct_hire_proposal_milestones.sum(:amount).to_i
   
   filmmaker = @proposal.filmmaker
   response = filmmaker.send_message(client, "#{filmmaker.name} declined your direct hire proposal.", "Direct Hire Proposal Declined") if filmmaker.present?
   
   respond_to do |format|
     format.js
     format.html { redirect_to :back }
   end 
  end
  
  private
  
  def find_proposal
    @proposal = DirectHireProposal.find(params[:proposal_id])
  end
  
end
