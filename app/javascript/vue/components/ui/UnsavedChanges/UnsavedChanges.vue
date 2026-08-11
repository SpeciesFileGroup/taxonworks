<template>
  <VTooltip
    v-if="compact"
    :content="message"
    class="unsaved-changes__compact"
    role="status"
    aria-live="polite"
  >
    <IconWarning class="w-4 h-4" />
  </VTooltip>
  <div
    v-else
    class="unsaved-changes"
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

defineOptions({ name: 'UnsavedChanges' })

const props = defineProps({
  // While true the record is being persisted: the state is already understood
  // by the user, so the indicator reports progress instead of the warning.
  saving: {
    type: Boolean,
    default: false
  },

  // Icon only, with the message moved into a tooltip. For rows too tight to
  // carry the label.
  compact: {
    type: Boolean,
    default: false
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

<style>
.unsaved-changes {
  display: flex;
  align-items: center;
  flex-shrink: 0;
  gap: var(--spacing-xxs);
  padding: var(--spacing-xxs) var(--spacing-xs);
  border: 1px solid var(--color-soft-warning-border);
  border-radius: var(--border-radius-small);
  background-color: var(--color-soft-warning-bg);
  color: var(--color-warning-on-surface);
  font-size: var(--font-size-xs);
  line-height: 1;
  white-space: nowrap;
}

.unsaved-changes--compact {
  padding: 0;
  border: none;
  background-color: transparent;
  cursor: help;
}
</style>
