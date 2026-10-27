<template>
  <span
    v-if="objectId"
    class="cursor-pointer text-xs"
    v-tooltip="`Click to copy ${objectType} ID`"
    @click="copyToClipboard"
    >ID: {{ objectId }}</span
  >
</template>

<script setup>
import { vTooltip } from '@/directives'

const props = defineProps({
  objectId: {
    type: [String, Number],
    default: undefined
  },

  objectType: {
    type: String,
    default: undefined
  }
})

function copyToClipboard() {
  navigator.clipboard.writeText(String(props.objectId)).then(() => {
    TW.workbench.alert.create('Copied to clipboard', 'notice')
  })
}
</script>
