<template>
  <label>
    <input
      type="checkbox"
      v-model="containerize">
    Containerize specimen with existing ones when catalog number already exists
  </label>
</template>

<script>

import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'
import { UpdateImportSettings } from '../../request/resources'

export default {
  computed: {
    containerize: {
      get () {
        return this.$store.getters[GetterNames.GetDataset].metadata.import_settings?.containerize_dup_cat_no
      },
      set (value) {
        UpdateImportSettings({
          import_dataset_id: this.dataset.id,
          import_settings: {
            containerize_dup_cat_no: value
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
