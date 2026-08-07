<template>
  <td>
    <div
      v-for="dataAttribute in item.dataAttributes[predicate.id]"
      :key="dataAttribute.uuid"
      class="d-block"
    >
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
        class="full_width"
        type="text"
        :value="dataAttribute.value"
        @change="
          (e) => {
            saveChanges({
              id: dataAttribute.id,
              objectId: item.id,
              predicateId: dataAttribute.predicateId,
              uuid: dataAttribute.uuid,
              value: e.target.value
            })
          }
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

  predicate: {
    type: Object,
    required: true
  },

  saveDataAttributeFunction: {
    type: Function,
    required: true
  }
})

const isUpdating = ref(false)

function saveChanges(item) {
  isUpdating.value = true

  props
    .saveDataAttributeFunction(item)
    .then(({ body }) => {
      const message = body?.id
        ? 'Attribute was successfully saved'
        : 'Attribute was successfully destroyed'

      TW.workbench.alert.create(message)
    })
    .catch(() => {})
    .finally(() => {
      isUpdating.value = false
    })
}
</script>
