json.array! @loans do |l| 
  t = loan_tag(l)
  json.gid l.to_global_id.to_s
  json.id l.id
  json.label t 
  json.label_html t 

  json.response_values do 
    if params[:method]
      json.set! params[:method], l.id
    end
  end 
end

