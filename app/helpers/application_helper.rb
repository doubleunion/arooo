module ApplicationHelper
  def body_classes
    classes = [controller_name, action_name]
    classes << 'members' if members_page?
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

  # now unused in favor of redcarpet markdown
  #def preserve_newlines(text)
  #  text ? text.split("\n").map { |p| h(p) }.join("<br />").html_safe : nil
  #end

  def google_analytics
    return unless Rails.env.production?

    code = <<-eos
      <script>
        (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
        (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
        m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
        })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

        ga('create', '#{GOOGLE_ANALYTICS_ID}', 'doubleunion.org');
        ga('send', 'pageview');

      </script>
    eos
    code.html_safe
  end

  def markdown(text)
    render_options = {
      # will remove from the output HTML tags inputted by user 
      filter_html:     true,
      # will insert <br /> tags in paragraphs where are newlines 
      # (ignored by default)
      hard_wrap:       true, 
      # hash for extra link options, for example 'nofollow'
      link_attributes: { rel: 'nofollow' }
      # more
      # will remove <img> tags from output
      # no_images: true
      # will remove <a> tags from output
      # no_links: true
      # will remove <style> tags from output
      # no_styles: true
      # generate links for only safe protocols
      # safe_links_only: true
      # and more ... (prettify, with_toc_data, xhtml)
    }
    renderer = Redcarpet::Render::HTML.new(render_options)
    extensions = {
      #will parse links without need of enclosing them
      autolink:           true,
      # blocks delimited with 3 ` or ~ will be considered as code block. 
      # No need to indent.  You can provide language name too.
      # ```ruby
      # block of code
      # ```
      fenced_code_blocks: true,
      # will ignore standard require for empty lines surrounding HTML blocks
      lax_spacing:        true,
      # will not generate emphasis inside of words, for example no_emph_no
      no_intra_emphasis:  true,
      # will parse strikethrough from ~~, for example: ~~bad~~
      strikethrough:      true,
      # will parse superscript after ^, you can wrap superscript in () 
      superscript:        true
      # will require a space after # in defining headers
      # space_after_headers: true
    }
    Redcarpet::Markdown.new(renderer, extensions).render(text).html_safe
  end
end
