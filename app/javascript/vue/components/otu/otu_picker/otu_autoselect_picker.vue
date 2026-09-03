<template>
  <AutoselectField
    :id="id"
    :preferences-key="preferencesKey"
    ref="autoselectRef"
    url="/otus/autoselect"
    param="otu_id"
    placeholder="Select an OTU"
    :autofocus="autofocus"
    :new-record-component="OtuNewModal"
    reset-on-select
    @select="onSelect"
  />
</template>

<script setup>
import { useTemplateRef } from 'vue'
import AutoselectField from '@/components/ui/AutoselectField.vue'
import OtuNewModal from '@/components/ui/AutoselectField/OtuNewModal.vue'
import { Otu } from '@/routes/endpoints'

defineProps({
  id: {
    type: String,
    default: undefined
  },
  preferencesKey: {
    type: String,
    default: undefined
  },
  autofocus: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['get-item'])

const autoselectRef = useTemplateRef('autoselectRef')

function onSelect(item) {
  Otu.find(item.id)
    .then(({ body }) => {
      emit('get-item', body)
    })
    .catch(() => {})
}

function setFocus() {
  autoselectRef.value?.$el?.querySelector('input')?.focus()
}

defineExpose({
  setFocus
})
</script>
