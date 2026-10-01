<template>
  <span class="middle">
    <IconWarning class="w-4 h-4 text-attention-color margin-small-right" />
    Warning, {{ count }} additional specimens identical except for whitespace are
    included.
  </span>
</template>

<script setup>
import IconWarning from '@/components/Icon/IconWarning.vue'

defineProps({
  count: {
    type: Number,
    required: true
  }
})
</script>
