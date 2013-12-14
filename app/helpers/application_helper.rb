module ApplicationHelper
  def body_classes
    classes = [controller_name, action_name]
    classes << 'admin' if admin_page?
    classes
  end

  def external_link_to(label, url, opts = {})
    link_to(label, url, { :target => '_blank' }.merge(opts))
  end
  
  def external_auto_link(url)
    auto_link(url, :html => { :target => '_blank' })
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
    format = '%b %e'
    format << ', %Y' unless timestamp.year == Time.now.year
    format << ' at %l:%M%P'

    timestamp.strftime(format)
  end

  def preserve_newlines(text)
    text ? text.split("\n").map { |p| h(p) }.join("<br />").html_safe : nil
  end

  def google_analytics
    return unless Rails.env.production?

    code = <<-eos
      <script type="text/javascript">
        var _gaq = _gaq || [];
        _gaq.push(['_setAccount', '#{GOOGLE_ANALYTICS_ID}']);
        _gaq.push(['_trackPageview']);
        (function() {
          var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
          ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
          var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
        })();
      </script>
    eos
    code.html_safe
  end
end
