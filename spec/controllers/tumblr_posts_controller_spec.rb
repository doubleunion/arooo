require 'spec_helper'

describe TumblrPostsController do
  describe 'GET index' do
    it 'returns http success' do
      get :index
      response.should redirect_to TUMBLR_URL
    end
  end
end
