function displayMessage(event) {
  message = undefined;

  if (event.origin !== "http://www.geo-locate.org") {
    message = "iframe url does not have permision to interact with me";
  }
  else {
    // All of the data parsing happens model side.
    document.getElementById("georeference_iframe_response").value = event.data;
  }
  return;
}

if (window.addEventListener) {
	window.addEventListener("message", displayMessage, false);
} else if (window.attachEvent) {
	window.attachEvent("onmessage", displayMessage);
}


