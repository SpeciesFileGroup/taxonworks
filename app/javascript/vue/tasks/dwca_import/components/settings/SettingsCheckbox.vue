<template>
  <div class="label-above">
    <label>
      <input
        type="checkbox"
        v-model="checkboxState">
      {{ description }}
    </label>
  </div>
</template>

<script>
import { GetterNames } from '@/tasks/dwca_import/store/getters/getters'
import { UpdateImportSettings } from '@/tasks/dwca_import/request/resources'
import { ActionNames } from '@/tasks/dwca_import/store/actions/actions'

export default {
  props: {
    // setting has a single key, the name of the key to store in import_settings
    // the value is the label/description to show next to the checkbox
    setting: {
      type: Object,
      required: true
    },
  },

  computed: {
    name() {
      return Object.keys(this.setting)[0]
    },
    description() {
      return Object.values(this.setting)[0]
    },

    checkboxState: {
      get() {
        return this.$store.getters[GetterNames.GetDataset].metadata?.import_settings?.[this.name]
      },

      set(value) {
        UpdateImportSettings({
          import_dataset_id: this.dataset.id,
          import_settings: {
            [this.name]: value
          }
        }).then(response => {
          this.$store.dispatch(ActionNames.LoadDataset, this.dataset.id)
        })
      }
    },

    dataset() {
      return this.$store.getters[GetterNames.GetDataset]
    }
  },
}
</script>
