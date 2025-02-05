<template>
  <VBtn
    color="primary"
    title="Copy selected columns to clipboard"
    :disabled="!predicateIds.length && !attributes.length"
    @click="copyToClipboard"
    >Copy columns to clipboard</VBtn
  >
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import useStore from '../store/store.js'

const props = defineProps({
  predicateIds: {
    type: Array,
    default: () => []
  },

  attributes: {
    type: Array,
    default: () => []
  }
})

const store = useStore()

function copyToClipboard() {
  const data = store.makeTextTableByColumns({
    predicateIds: props.predicateIds,
    attributes: props.attributes.toSorted()
  })

  navigator.clipboard.writeText(data).then(() => {
    TW.workbench.alert.create('Copied to clipboard', 'notice')
  })
}
</script>
