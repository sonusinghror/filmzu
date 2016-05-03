class Monologue::Admin::CommentsController < Monologue::Admin::BaseController
  def show
    @comments = Monologue::Blogcomment.all
  end
  
  def update
    @comment = Monologue::Blogcomment.find(params[:id])
    @comment.is_active = @comment.is_active ? false : true
    @comment.save
    flash[:notice] = "Comment has #{@comment.is_active ? 'Apporved' : 'Un-Approved'} successfully."
    redirect_to admin_comments_path
  end

  def destroy
    @comment = Monologue::Blogcomment.find(params[:id])
    @comment.destroy
    flash[:notice] = "Comment has deleted successfully."
    redirect_to admin_comments_path
  end

end