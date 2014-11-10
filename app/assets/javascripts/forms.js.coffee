# forms.js.coffee
# A temporary place to include form-related javascripts

# A page can not have more than one form with required data
bind_required_fields_and_submit = () ->
  $("form input.required_for_submit").change ->
    empty = false
    $("form input.required_for_submit").each ->
      empty = true if $(this).val() is ""
      return

    if empty
      $("#submit_with_required").attr "disabled", "disabled"
    else
      $("#submit_with_required").removeAttr "disabled"
    return
  return

$(document).on 'ready page:load', ->
  bind_required_fields_and_submit();  
return

