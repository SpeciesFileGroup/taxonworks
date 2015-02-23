#sources.js.coffee 

toggle_source_form_fields = (button) ->
  to_show = button.value.split('::')[1].toLowerCase()
  $('[id^=fields_for_]').hide()
  $('#fields_for_' + to_show).show()
  for f in $('#fields_for_'+to_show+'input,textarea,select')
    f.value = null
  $('#source_bibtex_type').val("")
  # need to remove ajax picker source too
  $('#fields_for_' + to_show).show()

$(document).on 'ready page:load', ->
  $("#fields_for_verbatim").hide()
  $("[id^=source_type_source]").click (event) ->
    toggle_source_form_fields(this) 
return

