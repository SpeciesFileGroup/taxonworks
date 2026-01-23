<template>
  <VBtn
    circle
    color="primary"
    :class="copied && 'pulse-primary'"
    @click="handleClick"
  >
    <IconCheckmark
      v-if="copied"
      class="w-4 h-4"
      title="Copied!"
    />
    <VIcon
      v-else
      title="Copy to clipboard"
      name="clip"
      x-small
      class="icon"
    />
  </VBtn>
</template>

<script setup>
import { ref } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import IconCheckmark from '@/components/Icon/IconCheckmark.vue'

const props = defineProps({
  text: {
    type: String,
    default: ''
  },

  title: {
    type: String,
    default: 'Copy to clipboard'
  }
})

const copied = ref(false)

function handleClick() {
  copyToClipboard()

  copied.value = true
  setTimeout(() => {
    copied.value = false
  }, 1500)
}

function copyToClipboard() {
  navigator.clipboard.writeText(props.text)
}
</script>
