<template>
  <div class="label-above">
    <label>
      <input
        type="checkbox"
        v-model="useExistingTaxonHierarchy">
      Taxon names without parentNameUsageID will match existing nomenclature instead of being children of Root
    </label>
  </div>
</template>

<script>

import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'
import { UpdateImportSettings } from '../../request/resources'

export default {
  computed: {
    useExistingTaxonHierarchy: {
      get () {
        return this.$store.getters[GetterNames.GetDataset].metadata?.import_settings?.use_existing_taxon_hierarchy
      },
      set (value) {
        UpdateImportSettings({
          import_dataset_id: this.dataset.id,
          import_settings: {
            use_existing_taxon_hierarchy: value
          }
        }).then(response => {
          this.$store.dispatch(ActionNames.LoadDataset, this.dataset.id)
        })
      }
    },
    dataset () {
      return this.$store.getters[GetterNames.GetDataset]
    }
  }
}
</script>
