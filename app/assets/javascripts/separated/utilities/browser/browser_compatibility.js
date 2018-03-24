/*
<div class="modal-mask">
  <div class="modal-wrapper">
    <div class="modal-container">
      <div class="modal-header">
        <h3 class="browsercompatibility-title">Browser upgrade needed</h3>
      </div>
      <div class="modal-body">
        <p>TaxonWorks has detected that you are using an outdated browser that will prevent you from accessing certain features. An update is required.</p>
      </div>
      <div class="modal-footer">
        <a href="http://outdatedbrowser.com/">Click to download a compatible browser</a>
      </div>
    </div>
  </div>
</div>
*/
var TW = TW || {};
TW.utilities = TW.utilities || {};
TW.utilities.browserCompatibility = TW.utilities.browserCompatibility || {};


TW.utilities.browserCompatibility = {

  incompatibilityBrowsersList: ['MSIE', 'Trident/'],

  injectMotal: function() {
    if(this.incompatibilityBrowser()) {
      $('<div class="modal-mask"> <div class="modal-wrapper"> <div class="modal-container"> <div class="modal-header"> <h3 class="browsercompatibility-title">Browser upgrade needed</h3> </div> <div class="modal-body"> <p>TaxonWorks has detected that you are using an outdated browser that will prevent you from accessing certain features. An update is required.</p></div><div class="modal-footer"><a href="http://outdatedbrowser.com/">Click to download a compatible browser</a> </div> </div> </div> </div>').appendTo( "body" );
    };
  },

  incompatibilityBrowser: function() {
    var ua = window.navigator.userAgent;
    for(var i = 0; i < this.incompatibilityBrowsersList.length; i++) {
      if(ua.indexOf(this.incompatibilityBrowsersList[i]) > 0) {
        return true
      }
    }
    return false;
  }
}

$(document).ready(function() {
  
  TW.utilities.browserCompatibility.injectMotal();
});