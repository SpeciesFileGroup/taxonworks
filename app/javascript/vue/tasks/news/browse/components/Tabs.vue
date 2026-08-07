<template>
  <div class="tabs">
    <div
      v-for="tab in tabs"
      :key="tab"
      :class="['tab', 'cursor-pointer', tab === value && 'active']"
      @click="() => (value = tab)"
    >
      {{ tab }}
    </div>
  </div>
</template>

<script setup>
defineProps({
  tabs: {
    type: Array,
    required: true
  }
})

const value = defineModel({
  type: String,
  default: undefined
})
</script>

<style scoped>
.tabs {
  display: flex;
  flex-direction: row;
  gap: 0.5rem;
}

.tab {
  padding: 0.5rem 1rem;
  border-radius: var(--border-radius-medium);
}

.tab:hover {
  background-color: var(--bg-hover);
}

.active {
  background-color: var(--badge-blue-bg);
  font-weight: bold;
}
</style>
