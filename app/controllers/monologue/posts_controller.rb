class Monologue::PostsController < Monologue::ApplicationController
  caches_page :index, :show, :feed , :if => Proc.new { current_user.nil? }

  def index
    @page = params[:page].nil? ? 1 : params[:page]
    @posts = Monologue::Post.published.page(@page)
  end
  
  def show
    if params[:blogcomment].present?
      post = Monologue::Post.default.where("monologue_posts_revisions.url = :url", {:url => params[:post_url]}).first
      comment = post.blogcomments.create(params[:blogcomment])
      post.blogcomments << comment
      if post.save
        flash[:notice] = "Thank you. Your comment has posted successfull."
      end
      @revision = post.posts_revisions.first
    else
      unless current_user
        post = Monologue::Post.published.where("monologue_posts_revisions.url = :url", {:url => params[:post_url]}).first
      else
        post = Monologue::Post.default.where("monologue_posts_revisions.url = :url", {:url => params[:post_url]}).first
      end
      if post.nil?
        not_found
        return
      end
      @revision = post.posts_revisions.first
    end
  end
  
  def update

  end

  def feed
    @posts = Monologue::Post.published.limit(25)
  end
end