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
  <VBadge
    v-else
    color="yellow"
    :class="['unsaved-indicator', `unsaved-indicator--${size}`]"
    role="status"
    aria-live="polite"
  >
    <IconWarning class="w-4 h-4" />
    <span>{{ message }}</span>
  </VBadge>
</template>

<script setup>
import { computed } from 'vue'
import IconWarning from '@/components/Icon/IconWarning.vue'
import VTooltip from '@/components/ui/VTooltip/VTooltip.vue'
import VBadge from '@/components/ui/VBadge/VBadge.vue'

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
/* Colors, radius and font size come from VBadge (color="yellow"). */
.unsaved-indicator {
  display: inline-flex;
  align-items: center;
  flex-shrink: 0;
  gap: var(--spacing-xxs);
  line-height: 1;
  white-space: nowrap;
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
