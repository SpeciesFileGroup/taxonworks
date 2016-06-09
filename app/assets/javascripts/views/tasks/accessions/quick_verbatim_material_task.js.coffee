# quick_verbatim_material_task.js.coffee

update_attribute_names = (link) ->
  new_id = new Date().getTime()
  regex = new RegExp("_update_", "g")
  for i in $('input[name*="_update_"]')
    do(i) ->
      a = $(i).attr('name').replace(regex, new_id) 
      b = $(i).attr('id').replace(regex, new_id) 
      $(i).attr(name: a, id: b)
  return  

bind_remove_row_link = (link) ->
  for i in $('a[class*="_update_"]')
    do(i) ->
      $(i).click (event) ->
        $(i).parents('.biocuration_totals_row').hide()
        event.preventDefault() 
      $(i).attr(class: 'remove_row')
  return

$(document).on 'ready page:load', ->
  $(".add_total_row").click (event) ->
    update_attribute_names(this)
    bind_remove_row_link(this)
    return
return

