# Organization

In `app/assets/stylesheets/`

* base/ - core element styles, covering the general defaults (i.e. color palette, white space, etc)
* views/ - css for classes that originate in `app/views/`
* helpers/ - css for classes that originate in `app/helpers/`
* vendor/ - css that references libraries that aren't TW origin
* tasks/ - css for TaxonWorks tasks (TODO: most task styles are in Vue components, clarify when to use this vs component scoped styles)

See also `app/assets/javascript/vue/assets/styles/`.

# CSS

* DO ALWAYS use shared styles libraries for buttons, links, and fonts for both SS and vue.js work

# Semantic palette

- Green is only used to indicate buttons or actions that will POST or PATCH to the database
- Red is only used to indicate buttons or actions that will DELETE from the database
- TODO: define semantic meaning for primary/blue color usage
- TODO: define semantic meaning for warning/yellow color usage
- TODO: define semantic meaning for muted/gray color usage for disabled or inactive states
