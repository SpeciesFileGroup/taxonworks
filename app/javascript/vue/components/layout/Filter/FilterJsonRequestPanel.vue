<template>
  <div class="panel content">
    <div class="flex-separate middle gap-small">
      <span class="word_break"> JSON Request: {{ queryString }} </span>
      <ButtonClipboard :text="queryString" />
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import ButtonClipboard from '@/components/ui/Button/ButtonClipboard.vue'

const props = defineProps({
  url: {
    type: String,
    default: ''
  }
})

const queryString = computed(() => {
  return props.url.length > 2048 ? 'URL too long for GET request' : props.url
})
</script>
