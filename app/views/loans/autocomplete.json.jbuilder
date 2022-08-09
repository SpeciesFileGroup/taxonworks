json.array! @loans do |l| 
  json.gid l.to_global_id.to_s
  json.id l.id
  json.label label_for_loan(l)
  json.label_html loan_autocomplete_tag(l)

  json.response_values do 
    if params[:method]
      json.set! params[:method], l.id
    end
  end 
end

