<template>
  <span class="middle">
    <VIcon
      class="margin-small-right"
      name="attention"
      color="attention"
      small
    />
    Warning, {{ count }} aditional specimens identical except for whitespace are included.
  </span>
</template>

<script setup>
import VIcon from 'components/ui/VIcon/index.vue'

defineProps({
  count: {
    type: Number,
    required: true
  }
})
</script>
