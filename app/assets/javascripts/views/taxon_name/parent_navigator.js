var TW = TW || {};
TW.views = TW.views || {};
TW.views.taxon_name = TW.views.taxon_name || {};
TW.views.taxon_name.parent_navigator = TW.views.taxon_name.parent_navigator || {};


Object.assign(TW.views.taxon_name.parent_navigator, {

	hideElements (elements) {
		elements.forEach(element => {
			element.classList.add('display-none')
		})
	},

	showElements (elements) {
		elements.forEach(element => {
			element.classList.remove('display-none')
		})
	},

	toggleView (event) {
		const value = event.target.value

		switch (value) {
			case 'valid':
				this.showElements(this.validElements)
				this.hideElements(this.invalidElements)
			break;
			case 'invalid':
				this.hideElements(this.validElements)
				this.showElements(this.invalidElements)
			break;
			case 'both':
				this.showElements(this.validElements)
				this.showElements(this.invalidElements)
			break;
		}
	},

	init () {
		const radioElements = document.querySelectorAll('input[name="display_herarchy"]')

		this.validElements = document.querySelectorAll('[data-valid="valid"]')
		this.invalidElements = document.querySelectorAll('[data-valid="invalid"]')

		radioElements.forEach(element => {
			element.addEventListener('click', this.toggleView.bind(this))
		})
	}
});

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector("#show_taxon_name_hierarchy")) {
  	TW.views.taxon_name.parent_navigator.init()
  }
})
