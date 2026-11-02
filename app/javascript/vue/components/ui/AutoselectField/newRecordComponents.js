// Shared model -> !n create-modal mapping. Single source of truth so AutoselectPicker
// and initializers/Autoselect/main.js don't each define their own copy of which
// component creates a new record for which model.
import OtuNewModal from './OtuNewModal.vue'
import TaxonNameNewModal from './TaxonNameNewModal.vue'

export const AUTOSELECT_NEW_RECORD_COMPONENTS = {
  otus: OtuNewModal,
  taxon_names: TaxonNameNewModal
}
