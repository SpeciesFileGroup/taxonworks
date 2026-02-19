<template>
  <fieldset
    class="ap-fieldset separate-bottom"
    :class="{ 'ap-fieldset--inactive': !enabled }"
  >
    <legend>
      <label class="ap-fieldset-legend-toggle middle gap-small cursor-pointer">
        <input
          :checked="enabled"
          type="checkbox"
          @change="enabled = $event.target.checked"
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
defineProps({
  label: {
    type: String,
    required: true
  },

  hint: {
    type: String,
    required: true
  }
})

const enabled = defineModel({ type: Boolean, default: false })
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
  font-weight: 600;
}

.ap-fieldset-hint {
  color: var(--text-muted-color);
  font-size: 0.9rem;
  line-height: 1.3;
}
</style>
