<template>
  <div
    class="panel content"
    :class="{ 'facet-container-highlight': highlight }"
  >
    <slot />
  </div>
</template>
<script setup>
defineProps({
  highlight: {
    type: Boolean,
    default: false
  }
})
</script>
<style scoped>
.facet-container-highlight {
  background-color: var(--soft-validation-bg-color);
}

:deep(h3) {
  margin-bottom: var(--spacing-xs);
}
</style>
