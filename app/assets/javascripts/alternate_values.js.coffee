# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'ready page:load', ->
  $(".remove-field").click (event) ->
#    alert "Delete answer by link_id."
    remove_fields(this)
    event.preventDefault() # Prevent link from following its href
    return

  $(".a-add").click (event) ->
#    alert "Add answer by link_id."
    a_fields(this)
    event.preventDefault() # Prevent link from following its href
    return

  $(".q-remove").click (event) ->
#    alert "Delete question by link_id."
    remove_fields(this)
    event.preventDefault() # Prevent link from following its href
    return

  $(".q-add").click (event) ->
#    alert "Add question by link_id."
    a_fields(this)
    event.preventDefault() # Prevent link from following its href
    return
return
