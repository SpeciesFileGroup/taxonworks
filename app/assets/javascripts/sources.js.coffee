# sources.js.coffee 

toggle_source_form_fields = (type_label) ->
  types = ['bibtex', 'verbatim', 'human']
  to_show = type_label.split('::')[1].toLowerCase()

  # show everything
  $('#fields_for_' + to_show).show()

  # hide not visible (we can't hide everything
  # and show because we lose content of inputs
  for f in types when f isnt to_show
    $('[id^=fields_for_'+f+']').hide()
    for k in $('#fields_for_'+f+' :input')
      k.value = null

  # misc form cleanup (for ajax/selects)
  if to_show != 'bibtex'
    $('#source_bibtex_type').val("")
    $('[name=source\\[serial_id\\]]').val("")

$(document).on 'ready page:load', ->
  if $('#source_edit_type').length
    current_type = $('#source_edit_type input[checked="checked"]').first()
    
    if $('form[id="new_source"]').length == 1 # current_type.val() == undefined
      # new record
      toggle_source_form_fields('Source::Bibtex')
      $('#source_type_sourcebibtex').attr('checked', true)
    else
      # existing record
      toggle_source_form_fields(current_type.val())
       # disable any option, you can't swap types
      for i in $('#source_edit_type :input')
        i.disabled = true

    $("[id^=source_type_source]").click (event) ->
      toggle_source_form_fields(this.value)
return

