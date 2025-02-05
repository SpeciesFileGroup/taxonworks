<template>
  <VBtn
    color="primary"
    circle
    title="Copy selected columns to clipboard"
    @click="copyToClipboard()"
  >
    <VIcon
      name="clip"
      x-small
      title="Copy selected columns to clipboard"
    />
  </VBtn>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
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
