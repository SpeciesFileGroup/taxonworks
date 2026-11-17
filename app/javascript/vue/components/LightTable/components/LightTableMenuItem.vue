<template>
  <button
    type="button"
    class="lt-menu-item"
    :disabled="disabled"
    @click="(e) => (disabled ? e.stopPropagation() : emit('click', e))"
  >
    <span class="lt-menu-item__label">
      <slot>{{ label }}</slot>
    </span>
    <kbd
      v-if="shortcut"
      class="lt-menu-item__shortcut"
    >{{ shortcut }}</kbd>
  </button>
</template>

<script setup>
defineProps({
  label: {
    type: String,
    default: ''
  },

  shortcut: {
    type: String,
    default: ''
  },

  disabled: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['click'])
</script>

<style scoped>
.lt-menu-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-md);
  width: 100%;
  padding: var(--spacing-xxs) var(--spacing-sm);
  font: inherit;
  font-size: var(--font-size-xs);
  text-align: left;
  color: var(--text-color);
  background: transparent;
  border: none;
  cursor: pointer;
}

.lt-menu-item:hover:not(:disabled),
.lt-menu-item:focus-visible {
  background: var(--bg-hover);
}

.lt-menu-item:focus-visible {
  outline: 2px solid var(--focus-ring);
  outline-offset: -2px;
}

.lt-menu-item:disabled {
  color: var(--text-muted-color);
  cursor: default;
}

.lt-menu-item__label {
  flex: 1;
  white-space: nowrap;
}

.lt-menu-item__shortcut {
  font-family: inherit;
  color: var(--text-muted-color);
}
</style>
