# depiction.js.coffee

toggle_source_form_fields = (type_label) ->
  types = ['otu', 'collecting_event', 'collection_object']
  to_show = type_label

  console.log(type_label);
  console.log(to_show);

  # show everything
  $('#fields_for_' + to_show).show()

  # hide not visible (we can't hide everything
  # and show because we lose content of inputs
  for f in types when f isnt to_show
    $('[id^=fields_for_'+f+']').hide()
   #for k in $('#fields_for_'+f+' :input')
   #  k.value = null

  # misc form cleanup (for ajax/selects)
  # if to_show != 'bibtex'
  #   $('#source_bibtex_type').val("")
  #   $('[name=source\\[serial_id\\]]').val("")

$(document).on 'ready page:load', ->
  if $('#depiction_edit').length
    current_type = $('#depiction_edit input[checked="checked"]').first()

    console.log(current_type.attr('id'))

    if current_type.val() == undefined
      # new record
      toggle_source_form_fields('collection_object')
      $('#collection_object').attr('checked', true)
    else
      # existing record
      toggle_source_form_fields(current_type.val())
       # disable any option, you can't swap types
      for i in $('#depiction_edit :input')
        i.disabled = true

    $("[id^=depiction_edit] :input").click (event) ->
      toggle_source_form_fields(this.id)
return

