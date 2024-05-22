<template>
  <VBtn
    color="primary"
    circle
    @click="copyToClipboard()"
  >
    <VIcon
      name="clip"
      x-small
    />
  </VBtn>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
const props = defineProps({
  text: {
    type: String,
    default: ''
  }
})

function copyToClipboard() {
  navigator.clipboard.writeText(props.text).then(() => {})
  TW.workbench.alert.create('Copied to clipboard', 'notice')
}
</script>
