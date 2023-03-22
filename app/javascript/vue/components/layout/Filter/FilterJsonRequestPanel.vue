<template>
  <div class="panel content">
    <div class="flex-separate middle">
      <span>
        JSON Request: {{ queryString }}
      </span>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  url: {
    type: String,
    default: ''
  }
})

const queryString = computed(() => {
  return props.url.length > 2048
    ? 'URL too long for GET request'
    : props.url
})

</script>
