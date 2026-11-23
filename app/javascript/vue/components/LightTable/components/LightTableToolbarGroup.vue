<template>
  <div
    class="lt-toolbar-group"
    :class="{ 'lt-toolbar-group--end': end }"
  >
    <slot />
  </div>
</template>

<script setup>
defineProps({
  end: {
    type: Boolean,
    default: false
  }
})
</script>

<style scoped>
.lt-toolbar-group {
  display: flex;
  align-items: center;
  gap: var(--spacing-xxs);
}

.lt-toolbar-group + .lt-toolbar-group {
  padding-left: var(--spacing-sm);
  border-left: 1px solid var(--border-color);
}

.lt-toolbar-group + .lt-toolbar-group--end {
  margin-left: auto;
  padding-left: 0;
  border-left: none;
}
</style>
