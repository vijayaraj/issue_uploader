module ApplicationHelper

  def formated_date(date)    
    date.to_datetime.strftime('%b %d, %Y')
  end
end
