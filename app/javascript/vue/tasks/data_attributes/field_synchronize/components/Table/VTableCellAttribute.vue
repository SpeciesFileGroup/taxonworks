<template>
  <td>
    <div>
      <VSpinner
        v-if="isUpdating"
        spinner-position="left"
        legend="Saving..."
        :logo-size="{
          width: '20px',
          height: '20px'
        }"
        :legend-style="{
          fontSize: '12px'
        }"
      />
      <input
        type="text"
        :value="item.attributes[attribute]"
        class="full_width"
        :disabled="disabled"
        @change="
          (e) =>
            saveChanges({
              item: item,
              attribute: attribute,
              value: e.target.value
            })
        "
      />
    </div>
  </td>
</template>

<script setup>
import { ref } from 'vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const props = defineProps({
  item: {
    type: Object,
    required: true
  },

  attribute: {
    type: String,
    required: true
  },

  disabled: {
    type: Boolean,
    default: false
  },

  saveAttributeFunction: {
    type: Function,
    required: true
  }
})

const isUpdating = ref(false)

async function saveChanges(item) {
  isUpdating.value = true

  props
    .saveAttributeFunction(item)
    .then(() => TW.workbench.alert.create('Attribute was successfully saved'))
    .catch(() => {})
    .finally(() => {
      isUpdating.value = false
    })
}
</script>
