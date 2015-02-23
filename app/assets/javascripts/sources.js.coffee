#sources.js.coffee 

toggle_source_form_fields = (button) ->
  to_show = button.value.split('::')[1].toLowerCase()
  $('[id^=fields_for_]').hide()
  $('#fields_for_' + to_show).show()
  for f in $('#fields_for_bibtex input,textarea')
    f.value = null
  $('#fields_for_' + to_show).show()

$(document).on 'ready page:load', ->
  $("#fields_for_verbatim").hide()
  $("[id^=source_type_source]").click (event) ->
    toggle_source_form_fields(this) 
return

