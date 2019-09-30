json.array! @notes do |t|
  json.id t.id
  json.label t.text
  json.label_html note_autocomplete_tag(t, params[:term])
  json.gid t.to_global_id.to_s

  json.note_object_global_id t.note_object.to_global_id.to_s

  json.note_object_id t.note_object_id
  json.note_object_type t.note_object_type

  json.response_values do 
    if params[:method]
      json.set! params[:method], t.id
    end
  end 
end

