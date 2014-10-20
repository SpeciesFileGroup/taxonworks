# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'ready page:load', ->
  $(".alternate-value-edit").click (event) ->
#    alert "Delete answer by link_id."
    edit_fields(this)
    event.preventDefault() # Prevent link from following its href
    return

  $(".alternate-value-remove").click (event) ->
#    alert "remove answer by link_id."
    remove_fields(this)
    #    a_fields(this)
    event.preventDefault() # Prevent link from following its href
    return

  $(".alternate-value-destroy").click (event) ->
#    alert "remove answer by link_id."
    destroy_fields(this)
    #    a_fields(this)
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

remove_fields = (rf_link) ->
  $(rf_link).prev(".destroy_field").attr "value", "1"
  $(rf_link).closest(".fields").hide()
  return
destroy_fields = (rf_link) ->
  $(rf_link).prev(".destroy_field").attr "value", "1"
  $(rf_link).closest(".fields").hide()
  return
add_fields = (af_link, association, content) ->
  new_id = new Date().getTime()
  regexp = new RegExp("new_" + association, "g")
  $(af_link).prev().insertBefore content.replace(regexp, new_id)
  return
a_fields = (af_link) ->
  #    af_link.attributes.content.value or $(af_link).attr('content')
  content = $(af_link).attr("content")
  association = $(af_link).attr("association")
  new_id = new Date().getTime()
  regex = new RegExp("new_" + association, "g")
  content = content.replace(regex, new_id)
  $(content).insertBefore $(af_link)
  return
