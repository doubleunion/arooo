class TumblrPostsController < ApplicationController
  def index
    redirect_to TUMBLR_URL
  end

  def show
    if @post = TumblrPost.find_by_tumblr_id(params[:id])
      redirect_to @post.post_url
    else
      redirect_to TUMBLR_URL
    end
  end
end
