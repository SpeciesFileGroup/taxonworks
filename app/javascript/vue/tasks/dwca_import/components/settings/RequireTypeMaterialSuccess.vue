<template>
  <div class="label-above">
    <label>
      <input
        type="checkbox"
        v-model="requireTypeMaterialSuccess"
      >
      Skip/error rows where type material creation fails
    </label>
  </div>
</template>

<script>

import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'
import { UpdateImportSettings } from '../../request/resources'

export default {
  computed: {
    requireTypeMaterialSuccess: {
      get () {
        return this.$store.getters[GetterNames.GetDataset].metadata?.import_settings?.require_type_material_success
      },
      set (value) {
        UpdateImportSettings({
          import_dataset_id: this.dataset.id,
          import_settings: {
            require_type_material_success: value
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
