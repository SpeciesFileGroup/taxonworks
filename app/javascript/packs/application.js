/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

/* import 'core-js/stable'
import 'regenerator-runtime/runtime' */
// Styles
import 'leaflet/dist/leaflet.css'
import 'tippy.js/dist/tippy.css'

require('../vue/tasks/citations/otus/main.js')
require('../vue/tasks/content/editor/main.js')
require('../vue/tasks/nomenclature/new_taxon_name/main.js')
require('../vue/tasks/loan/main.js')
require('../vue/tasks/observation_matrices/matrix_row_coder/main.js')
require('../vue/initializers/annotator_init/main.js')
require('../vue/initializers/otu_radial_init/main.js')
require('../vue/initializers/otu_button_init/main.js')
require('../vue/initializers/navigation_radial/main.js')
require('../vue/initializers/collection_object_radial/main.js')
require('../vue/initializers/pdfViewer/main.js')
require('../vue/initializers/default_confidence/main.js')
require('../vue/initializers/tagButton/main.js')
require('../vue/initializers/quick_citation_init/main.js')
require('../vue/initializers/browse_nomenclature/main.js')
require('../vue/initializers/pinboard_navigator/main.js')
require('../vue/initializers/soft_validations/main.js')
require('../vue/tasks/type_specimens/main.js')
require('../vue/tasks/nomenclature/new_combination/main.js')
require('../vue/tasks/browse_annotations/main.js')
require('../vue/tasks/descriptor/main.js')
require('../vue/tasks/observation_matrices/new/main.js')
require('../vue/tasks/clipboard/main.js')
require('../vue/tasks/uniquify/people/main.js')
require('../vue/tasks/single_bibtex_source/main.js')
require('../vue/tasks/nomenclature/by_source/main.js')
require('../vue/tasks/people/author_by_letter/main.js')
require('../vue/tasks/collecting_events/filter/main.js')
require('../vue/tasks/digitize/main.js')
require('../vue/tasks/labels/print_labels/main.js')
require('../vue/tasks/projects/preferences/main.js')
require('../vue/tasks/asserted_distribution/new_asserted_distribution/main.js')
require('../vue/tasks/images/new_image/main.js')
require('../vue/tasks/images/filter/main.js')
require('../vue/tasks/sources/hub/main.js')
require('../vue/tasks/nomenclature/filter/main.js')
require('../vue/tasks/observation_matrices/image/main.js')
require('../vue/tasks/observation_matrices/hub/main.js')
require('../vue/tasks/observation_matrices/dashboard/main.js')
require('../vue/tasks/nomenclature/stats/main.js')
require('../vue/tasks/otu/browse_asserted_distributions/main.js')
require('../vue/tasks/collection_objects/filter/main.js')
require('../vue/tasks/sources/new_source/main.js')
require('../vue/tasks/otu/browse/main.js')
require('../vue/tasks/collection_objects/slide_breakdown/main.js')
require('../vue/tasks/biological_relationships/composer/main.js')
require('../vue/tasks/nomenclature/match/main.js')
require('../vue/tasks/controlled_vocabularies/manage/main.js')
require('../vue/tasks/collection_objects/match/main.js')
require('../vue/tasks/sources/filter/main.js')
require('../vue/tasks/collecting_events/new_collecting_event/main.js')
require('../vue/tasks/interactive_keys/main.js')
require('../vue/tasks/extracts/new_extract/main.js')
require('../vue/tasks/namespaces/new_namespace/main.js')
require('../vue/data/downloads/index.js')
require('../vue/tasks/dwca_import/main.js')
require('../vue/tasks/dwc/dashboard/index.js')
require('../vue/tasks/administration/data/index.js')
require('../vue/tasks/graph/object_graph/main.js')
require('../vue/tasks/controlled_vocabularies/biocurations/main.js')
require('../vue/tasks/extracts/filter/main.js')
require('../vue/tasks/otu/filter/main.js')
require('../vue/tasks/collection_objects/stepwise/determinations/main.js')
