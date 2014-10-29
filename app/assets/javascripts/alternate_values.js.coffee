# alternate_values.js.coffee
# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

destroy_record = (dr_link) ->
  $(dr_link).prev('.destroy_field').attr "value", "1"
  $(dr_link).closest('.alternate-value-record').hide()
  return

remove_record = (rr_link) ->
  $(rr_link).prev(".destroy_field").attr "value", "1"
  $(rr_link).closest(".fields").hide()
  return

edit_record = (er_link) ->
  $(er_link).prev(".edit_field").attr "value", "1"
  $(er_link).closest(".fields").hide()
  return

add_record = (ar_link) ->
  #    af_link.attributes.content.value or $(af_link).attr('content')
  content = $(ar_link).attr("content")
  association = $(ar_link).attr("association")
  new_id = new Date().getTime()
  regex = new RegExp("new_" + association, "g")
  content = content.replace(regex, new_id)
  $(content).insertBefore $(ar_link)
  return

bind_alternate_value_remove = (link) ->
  # alert 'Remove binding triggered by new link.'
  $('a', $(link).prev('div.alternate-value-record')).click (event) ->
    # alert 'Remove triggered by new link.'
    destroy_record(this)
    event.preventDefault() # Prevent link from following its href
    return
  return

$(document).on 'ready page:load', ->
  $(".alternate-value-edit").click (event) ->
    #    alert "Delete answer by link_id."
    edit_record(this)
    event.preventDefault() # Prevent link from following its href
    return

  $(".alternate-value-add").click (event) ->
    # alert "Add alternate_value by link_id."
    add_record(this)
    bind_alternate_value_remove(this)
    event.preventDefault() # Prevent link from following its href
    return

  $(".alternate-value-destroy").click (event) ->
    #    alert "remove answer by link_id."
    destroy_record(this)
    #    a_fields(this)
    event.preventDefault() # Prevent link from following its href
    return

  $(".alternate-value-remove").click (event) ->
    # alert "remove alternate_value by link_id."
    destroy_record(this)
    event.preventDefault() # Prevent link from following its href
    return

#  $(".q-remove").click (event) ->
##    alert "Delete question by link_id."
#    remove_fields(this)
#    event.preventDefault() # Prevent link from following its href
#    return
#
#  $(".q-add").click (event) ->
##    alert "Add question by link_id."
#    a_fields(this)
#    event.preventDefault() # Prevent link from following its href
#    return
return

