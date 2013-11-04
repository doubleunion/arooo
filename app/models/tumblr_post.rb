require 'net/http'
require 'uri'

class TumblrPost < ActiveRecord::Base
  paginates_per 5

  API_BASE = 'http://api.tumblr.com/v2'

  validates :tumblr_id, :note_count, :blog_name, :post_url, :slug,
    :tumblr_type, :state, :format, :reblog_key, :short_url, :api_repr,
    :published_at, :last_scraped_at, :presence => true

  validates :tags, :presence => true, :allow_blank => true

  serialize :tags
  serialize :photos

  default_scope { order('published_at DESC') }

  def display_title
    title || tumblr_type.capitalize
  end

  def photo?
    tumblr_type == 'photo'
  end

  def api_repr
    JSON.parse(read_attribute(:api_repr))
  end

  def api_repr=(repr)
    write_attribute(:api_repr, repr.to_json)
  end

  def to_param
    "#{tumblr_id}-#{slug}"
  end

  class << self
    NOT_NULL_ATTRS = %w(blog_name post_url slug state format reblog_key
      short_url note_count tags)

    NULL_ATTRS = %w(title body caption photos)

    def find_or_create_from_api_repr(api_repr)
      tumblr_id = api_repr.fetch('id')

      (find_by_tumblr_id(tumblr_id) || new).tap do |post|
        post.tumblr_id    = tumblr_id
        post.tumblr_type  = api_repr.fetch('type')
        post.api_repr     = api_repr
        post.published_at = DateTime.parse(api_repr.fetch('date'))

        NOT_NULL_ATTRS.each do |attr|
          post.send(:"#{attr}=", api_repr.fetch(attr))
        end

        NULL_ATTRS.each do |attr|
          post.send(:"#{attr}=", api_repr.fetch(attr, nil))
        end

        post.last_scraped_at = Time.now
        post.save!
      end
    end

    def scrape_all
      get_posts.each do |api_repr|
        post = find_or_create_from_api_repr(api_repr)
      end
    end

    def get_posts
      uri = URI.parse(request_url)
      response = Net::HTTP.get_response(uri)

      unless response.code == '200'
        raise "Invalid Tumblr API response: #{response.code}"
      end

      JSON.parse(response.body).fetch('response').fetch('posts')
    end

    def request_url
      "#{API_BASE}/blog/#{TUMBLR_BASE}/posts/?api_key=#{consumer_key}"
    end

    def consumer_key
      ENV['TUMBLR_CONSUMER_KEY']
    end
  end
end
