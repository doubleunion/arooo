class TumblrPostsController < ApplicationController
  def index
    @posts = TumblrPost.page(params[:page])
    @recent_posts = TumblrPost.limit(10)
  end

  def show
    unless @post = TumblrPost.find_by_tumblr_id(params[:id])
      flash[:error] = 'Sorry, that post could not be found'
      redirect_to :root and return
    end
  end
end
