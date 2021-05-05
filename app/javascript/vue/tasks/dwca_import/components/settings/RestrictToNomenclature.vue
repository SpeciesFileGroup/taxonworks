<template>
  <label>
    <input
      type="checkbox"
      v-model="restrictToExistingNomenclature">
    Restrict import to existing nomenclature only
  </label>
</template>

<script>

import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'
import { UpdateImportSettings } from '../../request/resources'

export default {
  computed: {
    restrictToExistingNomenclature: {
      get () {
        return this.$store.getters[GetterNames.GetDataset].metadata.import_settings?.restrict_to_existing_nomenclature
      },
      set (value) {
        UpdateImportSettings({
          import_dataset_id: this.dataset.id,
          import_settings: {
            restrict_to_existing_nomenclature: value
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
