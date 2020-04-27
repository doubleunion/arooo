module ApplicationHelper
  def body_classes
    classes = [controller_name, action_name]
    classes << "members-layout" if members_page?
    classes
  end

  def external_link_to(label, url, opts = {})
    link_to(label, url, {target: "_blank"}.merge(opts))
  end

  def external_auto_link(url)
    auto_link(url, html: {target: "_blank"})
  end

  def s3_url(name)
    "#{S3_BUCKET}/#{name}"
  end

  def html_title
    if content_for?(:title)
      yield(:title)
    else
      "Double Union | A hacker/maker space for women in San Francisco"
    end
  end

  def html_description
    if content_for?(:description)
      yield(:description)
    else
      "A hacker/maker space for women in San Francisco"
    end
  end

  def pretty_timestamp(timestamp)
    format = "%b %e"
    format << ", %Y" unless timestamp.year == Time.now.year
    format << " at %l:%M%P"

    timestamp.strftime(format)
  end

  # now unused in favor of redcarpet markdown
  # def preserve_newlines(text)
  #  text ? text.split("\n").map { |p| h(p) }.join("<br />").html_safe : nil
  # end

  def google_analytics
    return unless Rails.env.production?

    code = <<-EOS
      <script>
        (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
        (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
        m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
        })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

        ga('create', '#{GOOGLE_ANALYTICS_ID}', 'doubleunion.org');
        ga('send', 'pageview');

      </script>
    EOS
    code.html_safe
  end

  @@markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(hard_wrap: true,
                                                                   prettify: true),
    no_intra_emphasis: true,
    tables: true,
    fenced_code_blocks: true,
    autolink: true,
    strikethrough: true,
    lax_spacing: true,
    space_after_headers: true,
    superscript: true,
    underline: true,
    highlight: true,
    quote: true)

  def markdown(text)
    return nil unless text
    @@markdown.render(text).html_safe
  end
end
