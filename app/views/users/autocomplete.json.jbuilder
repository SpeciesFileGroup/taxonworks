json.array! @users do |t|
  json.id t.id
  json.label t.name 
  json.label_html t.name + ' ' + content_tag(:span, t.email, class: [:feedback, 'feedback-thin', 'feedback-primary']).html_safe
  json.gid t.to_global_id.to_s

  json.response_values do 
    if params[:method]
      json.set! params[:method], t.id
    end
  end 
end

