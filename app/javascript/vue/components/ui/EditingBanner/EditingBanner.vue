<template>
  <div class="editing-banner">
    <span class="editing-banner__title">{{ title }}</span>
    <span class="editing-banner__label">
      <slot>
        <span v-html="label" />
      </slot>
    </span>
    <VBtn
      icon
      color="primary"
      variant="tonal"
      title="Discard changes and close the editor"
      @click="emit('close')"
    >
      <IconClose class="w-4 h-4" />
    </VBtn>
  </div>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import IconClose from '@/components/Icon/IconClose.vue'

defineOptions({ name: 'EditingBanner' })

defineProps({
  label: {
    type: String,
    default: undefined
  },

  title: {
    type: String,
    default: 'Editing'
  }
})

const emit = defineEmits(['close'])
</script>

<style>
.editing-banner {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  margin-bottom: var(--spacing-lg);
  padding: var(--spacing-sm) var(--spacing-md);
  background-color: var(--color-soft-primary-bg);
  border-left: 3px solid var(--color-primary);
  border-radius: var(--border-radius-small);
  color: var(--color-on-soft-primary);
}

.editing-banner__title {
  flex-shrink: 0;
  font-weight: var(--font-weight-semibold);
}

.editing-banner__label {
  flex-grow: 1;
}
</style>
