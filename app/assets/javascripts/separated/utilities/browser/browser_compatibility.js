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

  injectModal: function() {
    const template = document.createElement('template')
  
    template.innerHTML = `
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
    `.trim()

    document.body.append(template.content.firstChild)
  },

  isIncompatibilityBrowser: function() {
    const ua = window.navigator.userAgent;

    return this.incompatibilityBrowsersList.some(browser => ua.indexOf(browser) > -1)
  },

  checkCompatibility: function () {
    if(this.isIncompatibilityBrowser()) {
      this.injectModal()
    }
  }
}

document.addEventListener('turbolinks:load', () => {
  TW.utilities.browserCompatibility.checkCompatibility()
})