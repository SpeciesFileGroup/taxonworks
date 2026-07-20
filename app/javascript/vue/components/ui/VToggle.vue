<template>
  <div
    v-tooltip="{
      content: title,
      placement: 'bottom'
    }"
  >
    <label class="v-toggle-switch">
      <input
        v-model="checked"
        type="checkbox"
        @click="emit('click', checked)"
      />
      <span>
        <div class="switch-icon">
          <slot />
        </div>
      </span>
    </label>
  </div>
</template>

<script setup>
import { vTooltip } from '@/directives'
import { computed } from 'vue'
import { useSizes, sizeProps } from '@/composables'

const props = defineProps({
  ...sizeProps,

  modelValue: {
    type: Boolean,
    default: false
  },

  onColor: {
    type: String,
    default: 'var(--color-primary)'
  },

  offColor: {
    type: String,
    default: 'var(--bg-muted)'
  },

  title: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['update:modelValue', 'click'])

const { semanticSize } = useSizes(props)

const toggleHeight = computed(() => `var(--size-${semanticSize.value})`)

const checked = computed({
  get() {
    return props.modelValue
  },
  set(value) {
    emit('update:modelValue', value)
  }
})
</script>

<style lang="scss">
.v-toggle-switch {
  --v-toggle-on-color: v-bind('props.onColor');
  --v-toggle-off-color: v-bind('props.offColor');
  --v-toggle-height: v-bind(toggleHeight);
  --v-toggle-width: calc(var(--v-toggle-height) * 12 / 7);
  --v-toggle-knob-size: calc(var(--v-toggle-height) - 4px);
  --v-toggle-travel: calc(
    var(--v-toggle-width) - var(--v-toggle-knob-size) - 4px
  );

  height: var(--v-toggle-height);
  display: block;
  position: relative;
  cursor: pointer;
  input {
    display: none;
    & + span {
      padding-left: calc(var(--v-toggle-width) + 2px);
      min-height: var(--v-toggle-height);
      line-height: var(--v-toggle-height);
      display: block;
      position: relative;
      white-space: nowrap;
      transition: color 0.3s ease;
      &:before,
      &:after {
        content: '';
        display: block;
        position: absolute;
      }
      &:before {
        top: 0;
        left: 0;
        width: var(--v-toggle-width);
        height: var(--v-toggle-height);
        box-sizing: border-box;
        border: 1px solid var(--border-color);
        border-radius: calc(var(--v-toggle-height) / 2);
        background: var(--v-toggle-off-color);
        transition: all 0.3s ease;
      }
      &:after {
        width: var(--v-toggle-knob-size);
        height: var(--v-toggle-knob-size);
        border-radius: 50%;
        background: var(--panel-bg-color);
        top: 2px;
        left: 2px;
        box-shadow: 0 1px 3px rgba(#121621, 0.1);
        transition: all 0.45s ease;
      }

      .switch-icon {
        display: flex;
        position: absolute;
        top: 2px;
        left: 2px;
        width: var(--v-toggle-knob-size);
        height: var(--v-toggle-knob-size);
        opacity: 0.7;
        justify-content: center;
        align-items: center;
        z-index: 1;
        transition: all 0.45s ease;
      }
    }
    &:checked {
      & + span {
        &:before {
          background: var(--v-toggle-on-color);
          border-color: color-mix(
            in srgb,
            var(--v-toggle-on-color) 75%,
            var(--text-color)
          );
        }
        &:after {
          background: var(--panel-bg-color);
          transform: translate(var(--v-toggle-travel), 0);
        }

        .switch-icon {
          transform: translate(var(--v-toggle-travel), 0);
          color: var(--color-primary);
          opacity: 1;
          &:after {
            transform: rotate(0deg) translate(0px, 0);
          }
        }
      }
    }
  }
}
</style>
