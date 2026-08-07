<template>
  <VBtn
    color="primary"
    circle
    :title="tooltip"
    :disabled="!hasColumns"
    @click="copyToClipboard()"
  >
    <VIcon
      name="clip"
      x-small
      :title="tooltip"
    />
  </VBtn>
</template>

<script setup>
import { computed } from 'vue'
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

const hasColumns = computed(
  () => props.attributes.length || props.predicateIds.length
)
const tooltip = computed(() =>
  hasColumns.value
    ? 'Copy selected columns to the clipboard'
    : 'Check columns first to copy to the clipboard'
)

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
