# Patch stripe-ruby-mock v2.5.8 for Ruby 3.1 compatibility.
#
# In Ruby 3.1, keyword arguments are strictly separated from positional
# arguments. The stripe gem calls execute_request with keyword arguments:
#
#   client.execute_request(method, url, api_base: ..., api_key: ...,
#                          headers: ..., params: ...)
#
# stripe-ruby-mock replaces execute_request with a block that captures all
# args via *args and forwards them. In Ruby 2.7, keyword args were auto-
# converted to/from a trailing hash. In Ruby 3.1, *args captures the keywords
# as a trailing hash, but mock_request won't accept that hash as a positional
# argument (it expects keyword args).
#
# Fix: capture both *args and **kwargs, and forward both.

module StripeMock
  class << self
    alias_method :original_start, :start

    def start
      return false if instance_variable_get(:@state) == 'live'
      instance = Instance.new
      instance_variable_set(:@instance, instance)
      Stripe::StripeClient.send(:define_method, :execute_request) do |*args, **kwargs|
        instance.mock_request(*args, **kwargs)
      end
      instance_variable_set(:@state, 'local')
    end
  end
end
