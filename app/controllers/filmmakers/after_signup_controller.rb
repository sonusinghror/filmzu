class Filmmakers::AfterSignupController < ApplicationController
  def build_params
    params.require(:Filmmakers).permit(:skills,:about,:location,:latitude,:longitude)
  end

  def portfolio
    #if request.post?
    #  @filmmaker = current_filmmaker
    #  @filmmaker.update_attributes(params["filmmaker"])
    #  #resume = current_filmmaker.reload.resume.reload
    #  # current_filmmaker.resume = UploadedDocument.new if current_filmmaker.resume.nil?
    #  # current_filmmaker.resume.update_attributes(params['filmmaker']['resume_attributes'])
    #  # file_url = current_filmmaker.resume.document.url

    #  if !@filmmaker.videos.any? && !@filmmaker.videos.pluck(:url).include?(params[:video_url])
    #    @filmmaker.videos.create(:url => params[:video_url]) if params.has_key?(:video_url)
    #    end
    #    @filmmaker.photos.create(:image => params[:image][:photo]) if params.has_key?(:image)
    #  else
    #  end
    #  redirect_to '/filmmakers/dashboard' if request.post?
    # end
    @popular_tags = Filmmaker.tag_counts_on(:skill).order('count desc').limit(3)
    if request.post?
      @filmmaker = current_filmmaker
      params[:filmmaker].merge!({:skill_list => params[:filmmaker][:skills]})
      @filmmaker.update_attributes(params[:filmmaker])
      @filmmaker.photos.create(:image => params[:image][:photo]) if params.has_key?(:image)
      @filmmaker.videos.create(:url => params[:video_url]) if params.has_key?(:video_url) && @filmmaker.videos.empty? || params[:video_url] != @filmmaker.videos.last.url 
    end
    if params[:popup]
      render :layout => 'popup'
    else
      redirect_to '/filmmakers/dashboard' if request.post?
    end  
  end

  def show
    @filmmaker = current_filmmaker
    # render_wizard
  end

  def update
    @filmmaker = Filmmaker.find(params[:filmmaker_id])
    params[:filmmaker][:status] = 'active' if step == steps.portfolio
    @filmmaker.attributes = params[:filmmaker].permit(:filmmaker_attribute)
    respond_to do |format|
      if @filmmaker.save
        format.html { redirect_to '/filmmakers/dashboard', notice: 'Portfolio was submitted successfully.' }
      else
        format.html {redirect_to :back}
      end
    end
    # render_wizard @filmmaker
    # @filmmaker = current_filmmaker
    # render_wizard
  end

private
  def redirect_to_finish_wizard
    redirect_to root_url, notice: "Thank you for signing up."
  end

end
