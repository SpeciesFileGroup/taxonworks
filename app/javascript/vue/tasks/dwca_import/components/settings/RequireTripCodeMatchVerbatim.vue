<template>
  <div class="label-above">
    <label>
      <input
        type="checkbox"
        v-model="requireTripCodeMatchVerbatim">
      Error records when computed Trip code will not match fieldNumber
    </label>
  </div>
</template>

<script>

import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'
import { UpdateImportSettings } from '../../request/resources'

export default {
  computed: {
    requireTripCodeMatchVerbatim: {
      get () {
        return this.$store.getters[GetterNames.GetDataset].metadata?.import_settings?.require_tripcode_match_verbatim
      },
      set (value) {
        UpdateImportSettings({
          import_dataset_id: this.dataset.id,
          import_settings: {
            require_tripcode_match_verbatim: value
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
