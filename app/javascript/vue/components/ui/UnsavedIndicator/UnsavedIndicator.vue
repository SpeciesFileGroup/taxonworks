<template>
  <VTooltip
    v-if="compact"
    :content="message"
    class="unsaved-indicator__compact"
    role="status"
    aria-live="polite"
  >
    <IconWarning class="w-4 h-4" />
  </VTooltip>
  <div
    v-else
    :class="['unsaved-indicator', `unsaved-indicator--${size}`]"
    role="status"
    aria-live="polite"
  >
    <IconWarning class="w-4 h-4" />
    <span>{{ message }}</span>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import IconWarning from '@/components/Icon/IconWarning.vue'
import VTooltip from '@/components/ui/VTooltip/VTooltip.vue'

defineOptions({ name: 'UnsavedIndicator' })

const props = defineProps({
  saving: {
    type: Boolean,
    default: false
  },

  compact: {
    type: Boolean,
    default: false
  },

  size: {
    type: String,
    default: 'small',
    validator: (value) => ['small', 'medium', 'large'].includes(value)
  },

  label: {
    type: String,
    default: undefined
  }
})

const message = computed(
  () => props.label || (props.saving ? 'Saving…' : 'You have unsaved changes.')
)
</script>

<style scoped>
.unsaved-indicator {
  display: inline-flex;
  align-items: center;
  flex-shrink: 0;
  gap: var(--spacing-xxs);
  border: 1px solid var(--color-soft-warning-border);
  border-radius: var(--border-radius-small);
  background-color: var(--color-soft-warning-bg);
  color: var(--color-warning-on-surface);
  font-size: var(--font-size-xs);
  line-height: 1;
  white-space: nowrap;
}

.unsaved-indicator--small {
  padding: var(--spacing-xxs) var(--spacing-xs);
}

.unsaved-indicator--medium {
  padding: var(--spacing-xs) var(--spacing-sm);
}

.unsaved-indicator--large {
  padding: var(--spacing-sm) var(--spacing-md);
  gap: var(--spacing-xs);
}

.unsaved-indicator__compact {
  display: inline-flex;
  align-items: center;
  flex-shrink: 0;
  color: var(--color-warning-on-surface);
  cursor: help;
}
</style>
