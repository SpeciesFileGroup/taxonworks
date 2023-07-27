<template>
  <div class="label-above">
    <label>
      <input
        type="checkbox"
        v-model="enableOrganizationDeterminers">
      Enable searching for Organization name in determinedBy field
    </label>
  </div>
</template>

<script>

import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'
import { UpdateImportSettings } from '../../request/resources'

export default {
  computed: {
    enableOrganizationDeterminers: {
      get () {
        return this.$store.getters[GetterNames.GetDataset].metadata?.import_settings?.enable_organization_determiners
      },
      set (value) {
        UpdateImportSettings({
          import_dataset_id: this.dataset.id,
          import_settings: {
            enable_organization_determiners: value
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
