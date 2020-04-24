class GithubAuth
  # Convenience wrapper for OmniAuth Github hash
  # Raises KeyError for require attrs, returns nil for optional ones

  attr_reader :original

  def initialize(original)
    @original = original
  end

  def provider
    original.fetch("provider")
  end

  def uid
    original.fetch("uid")
  end

  def username
    original.fetch("extra").fetch("raw_info").fetch("login")
  end

  def name
    original["info"].try(:fetch, "name", nil)
  end

  def email
    original["info"].try(:fetch, "email", nil)
  end
end
