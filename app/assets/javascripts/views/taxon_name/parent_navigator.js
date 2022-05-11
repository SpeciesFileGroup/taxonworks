var TW = TW || {};
TW.views = TW.views || {};
TW.views.taxon_name = TW.views.taxon_name || {};
TW.views.taxon_name.parent_navigator = TW.views.taxon_name.parent_navigator || {};


Object.assign(TW.views.taxon_name.parent_navigator, {

	addElementsClass (tag, klass) {
		const elements = document.querySelectorAll(tag)

		elements.forEach(element => {
			element.classList.add(klass)
		})
	},

	removeElementsClass (tag, klass) {
		const elements = document.querySelectorAll(tag)

		elements.forEach(element => {
			element.classList.remove(klass)
		})
	},

	toggleView (event) {
		const value = event.target.value

		switch (value) {
			case 'valid':
				this.removeElementsClass('[data-valid="valid"]', 'display-none')
				this.addElementsClass('[data-valid="invalid"]', 'display-none')
			break;
			case 'invalid':
				this.addElementsClass('[data-valid="valid"]', 'display-none')
				this.removeElementsClass('[data-valid="invalid"]', 'display-none')
			break;
			case 'both':
				this.removeElementsClass('[data-valid="valid"]', 'display-none')
				this.removeElementsClass('[data-valid="invalid"]', 'display-none')
			break;
		}
	},

	init () {
		const radioElements = document.querySelectorAll('input[name="display_herarchy"]')

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
