<template>
  <div :title="title">
    <label class="toggle-switch">
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
import { computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false
  },

  onColor: {
    type: String,
    default: 'var(--color-toggle-active)'
  },

  offColor: {
    type: String,
    default: 'var(--bg-color)'
  },

  title: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['update:modelValue', 'click'])

const checked = computed({
  get() {
    return props.modelValue
  },
  set(value) {
    emit('update:modelValue', value)
  }
})
</script>
<style lang="scss" scoped>
.toggle-switch {
  height: 28px;
  display: block;
  position: relative;
  cursor: pointer;
  input {
    display: none;
    & + span {
      padding-left: 50px;
      min-height: 26px;
      line-height: 26px;
      display: block;
      position: relative;
      white-space: nowrap;
      transition: color 0.3s ease;
      &:before,
      &:after {
        content: '';
        display: block;
        position: absolute;
        border-radius: 12px;
      }
      &:before {
        top: 0;
        left: 0;
        width: 48px;
        height: 28px;
        background: v-bind('props.offColor');
        transition: all 0.3s ease;
      }
      &:after {
        width: 24px;
        height: 24px;
        background: var(--panel-bg-color);
        top: 2px;
        left: 3px;
        box-shadow: 0 1px 3px rgba(#121621, 0.1);
        transition: all 0.45s ease;
      }

      .switch-icon {
        display: flex;
        position: absolute;
        top: 2px;
        left: 3px;
        width: 24px;
        height: 24px;
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
          background: v-bind('props.onColor');
        }
        &:after {
          background: var(--panel-bg-color);
          transform: translate(18px, 0);
        }

        .switch-icon {
          transform: translate(18px, 0);
          &:after {
            transform: rotate(0deg) translate(0px, 0);
          }
        }
      }
    }
  }
}
</style>
