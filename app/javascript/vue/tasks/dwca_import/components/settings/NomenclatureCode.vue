<template>
  <div class="field ">
    <label>Nomenclature code: </label>
    <select v-model="nomenclatureCode">
      <option
        v-for="code in codes"
        :key="code"
        :value="code"
      >
        {{ code.toUpperCase() }}
      </option>
    </select>
  </div>
</template>

<script>

import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'
import { UpdateImportSettings } from '../../request/resources'

const CODES = {
  ICZN: 'iczn',
  ICN: 'icn'
}

export default {
  data () {
    return {
      codes: Object.values(CODES)
    }
  },

  computed: {
    nomenclatureCode: {
      get () {
        return this.$store.getters[GetterNames.GetDataset].metadata?.import_settings?.nomenclature_code || CODES.ICZN
      },
      set (value) {
        UpdateImportSettings({
          import_dataset_id: this.dataset.id,
          import_settings: {
            nomenclature_code: value
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