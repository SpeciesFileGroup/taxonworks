<template>
  <div class="label-above">
    <label>
      <input
        type="checkbox"
        v-model="inputValue"
      />
      {{ label }}
    </label>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from 'vuex'
import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'
import { UpdateImportSettings } from '../../request/resources'

const props = defineProps({
  label: {
    type: String,
    required: true
  },

  property: {
    type: String,
    required: true
  }
})

const store = useStore()
const dataset = computed(() => store.getters[GetterNames.GetDataset])

const inputValue = computed({
  get() {
    return store.getters[GetterNames.GetDataset].metadata?.import_settings[
      props.property
    ]
  },

  set(value) {
    UpdateImportSettings({
      import_dataset_id: dataset.value.id,
      import_settings: {
        [props.property]: value
      }
    }).then((_) => {
      store.dispatch(ActionNames.LoadDataset, dataset.value.id)
    })
  }
})
</script>
