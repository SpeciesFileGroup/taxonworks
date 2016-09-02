function displayMessage(event) {
  message = undefined
  if (event.origin != "http://www.museum.tulane.edu") {
    message = "iframe url does not have permision to interact with me";
  }
  else {
    // All of the data parsing happens model side.
    document.getElementById("georeference_iframe_response").value = event.data
  }
}

window.addEventListener("message", function(event){
    displayMessage(event);
});
