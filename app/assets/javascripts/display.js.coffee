# display.js.coffee
# A temporary place to write display altering bindings 


render_attribute_set_headers = () ->
 for i in $('.attribute_set')
    do (i) ->
      title = '<div class="attribute_set_title">' + $(i).data().title + '<div>'
      $(i).prepend(title)
  return 

$(document).on 'ready page:load', ->
  render_attribute_set_headers()  
return

