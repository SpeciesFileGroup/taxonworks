
# alternate_values.coffee
# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

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
#return

#edit_record_c = (er_link) ->
#  $(er_link).prev(".destroy_field").attr "value", "1"
#  $(er_link).closest(".fields").hide()
#  return
#destroy_record_c = (dr_link) ->
#  $(dr_link).prev(".destroy_field").attr "value", "1"
#  $(dr_link).closest(".fields").hide()
#  return
#add_record_c = (ar_link, association, content) ->
#  new_id = new Date().getTime()
#  regexp = new RegExp("new_" + association, "g")
#  $(af_link).prev().insertBefore content.replace(regexp, new_id)
#  return
#a_fields = (af_link) ->
#  #    af_link.attributes.content.value or $(af_link).attr('content')
#  content = $(af_link).attr("content")
#  association = $(af_link).attr("association")
#  new_id = new Date().getTime()
#  regex = new RegExp("new_" + association, "g")
#  content = content.replace(regex, new_id)
#  $(content).insertBefore $(af_link)
#  return
#
#  $(document).on 'ready page:load', ->
#  $(".alternate-value-edit").click (event) ->
##    alert "Delete answer by link_id."
#    edit_record(this)
#    event.preventDefault() # Prevent link from following its href
#    return
#
#  $(".alternate-value-destroy").click (event) ->
##    alert "remove answer by link_id."
#    destroy_record(this)
#    #    a_fields(this)
#    event.preventDefault() # Prevent link from following its href
#    return
#
