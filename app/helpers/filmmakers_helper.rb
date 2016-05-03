module FilmmakersHelper
  
  def filmmaker_completed_projects(filmmaker_id)
    filmmaker = Filmmaker.find(filmmaker_id)
    return 0 unless filmmaker.present?
    filmmaker.project_stats('completed_projects').count
  end

  def proposal_created_hours(date)
    rem_time = Time.now.utc - date.utc
    min, sec = rem_time.divmod(60)
    hour, min = min.divmod(60)
    day, hour = hour.divmod(24)
    if day.zero? 
      hour.zero? ? (min.zero? ? "less than a minute" : "#{pluralize(min, "minute")} ago") : "#{pluralize(hour, "hour")} ago"
    else
      hour.zero? ? "#{pluralize(day, "day")} ago" : "#{pluralize(day, "day")} #{pluralize(hour, "hour")} ago"
    end
  end
end
