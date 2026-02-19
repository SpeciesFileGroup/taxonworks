<template>
  <fieldset
    class="ap-fieldset separate-bottom"
    :class="{ 'ap-fieldset--inactive': !enabled }"
  >
    <legend>
      <label class="ap-fieldset-legend-toggle">
        <input
          :checked="enabled"
          type="checkbox"
          @change="emit('update:modelValue', $event.target.checked)"
        />
        {{ label }}
      </label>
    </legend>

    <div
      v-if="!enabled"
      class="ap-fieldset-hint"
    >
      {{ hint }}
    </div>

    <slot v-else />
  </fieldset>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false
  },

  label: {
    type: String,
    required: true
  },

  hint: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const enabled = computed(() => props.modelValue)
</script>

<style lang="scss" scoped>
.ap-fieldset {
  border: 1px solid var(--border-color);
  padding: 0.5rem 0.75rem;
  border-radius: var(--border-radius-small);
}

.ap-fieldset--inactive {
  opacity: 0.88;
}

.ap-fieldset-legend-toggle {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  font-weight: 600;
  cursor: pointer;
}

.ap-fieldset-hint {
  color: var(--text-muted-color);
  font-size: 0.9rem;
  line-height: 1.3;
}
</style>
