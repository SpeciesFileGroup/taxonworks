# georeferences_values.js.coffee
# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# This needs lots of tuning
displayMessage = (evt) ->
  message = undefined
  if evt.origin isnt "http://www.museum.tulane.edu"
    message = "iframe url does not have permision to interact with me"
  else 
    # All of the data parsing happens model side.
    document.getElementById("georeference_iframe_response").value = evt.data
  return

if window.addEventListener
  # For standards-compliant web browsers
  window.addEventListener "message", displayMessage, false
else
  window.attachEvent "onmessage", displayMessage
