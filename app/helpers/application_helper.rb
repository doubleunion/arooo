module ApplicationHelper
  def external_link_to(label, url, opts = {})
    link_to(label, url, { :target => '_blank' }.merge(opts))
  end

  def pretty_timestamp(timestamp)
    format = '%b %e'
    format << ', %Y' unless timestamp.year == Time.now.year
    format << ' at %l:%M%P'

    timestamp.strftime(format)
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
