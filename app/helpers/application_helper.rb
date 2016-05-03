module ApplicationHelper
  def flash_class(level)
      case level
      when :notice then "alert alert-info alert-dismissible flash_message"
      when :success then "alert alert-success alert-dismissible flash_message"
      when :error then "alert alert-danger alert-dismissible flash_message"
      when :alert then "alert alert-danger alert-dismissible flash_message"
      end
  end

  def comment
    # use this keyword in the views, to comment-out stuff...
  end

  def shorten(args)
    if args[:counter].present?
      @counter = args[:counter]
    end
    formatted = false
    if args[:formatted].present?
      formatted = args[:formatted]
    end
    show_more_anyways = false
    if args[:show_more] == true
      show_more = true
    end
    length = args[:length]
    text = args[:text]
    partial = args[:partial]
    output = truncate(text, :length => length, :omission => '...').html_safe
    if formatted
      output = simple_format(output)
    end
    more_button = render :partial => partial
    output += more_button if text.length > length or show_more
    output
  end

  def google_analytics_js(id = nil)

    content_tag(:script, :type => 'text/javascript') do
      raw "var _gaq = _gaq || [];
        _gaq.push(['_setAccount', 'UA-38653918-1']);
        _gaq.push(['_trackPageview']);

        (function() {
          var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
          ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
          var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
        })();"
    end if !id.blank? && Rails.env.production?
  end

  #Youtube Links to Embed Code
  def youtube_embed(youtube_url)
    if youtube_url[/youtu\.be\/([^\?]*)/]
      youtube_id = $1
    else
      # Regex from # http://stackoverflow.com/questions/3452546/javascript-regex-how-to-get-youtube-video-id-from-url/4811367#4811367
      youtube_url[/^.*((v\/)|(embed\/)|(watch\?))\??v?=?([^\&\?]*).*/]
      youtube_id = $5
    end
    %Q{<iframe title="YouTube video player" width="640" height="390" src="http://www.youtube.com/embed/#{ youtube_id }" frameborder="0" allowfullscreen></iframe>}
  end

  def chronic_date(date)
    duration = Time.diff(date, Time.now, '%y %M %w %d %H %N')
    human_readable_time = []
    ["year", "month", "week", "day", "hour", "minute"].each do |time|
      if duration[time.to_sym] > 0
        human_readable_time << pluralize(duration[time.to_sym], time)
      end    
    end
    if human_readable_time.blank?
      human_readable_time << pluralize(duration[:second], 'second')    
    end  
    human_readable_time.join(" ") + " ago" 
  end  
  
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = (column == sort_column) ? "current #{sort_direction}" : nil
    direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end

end
