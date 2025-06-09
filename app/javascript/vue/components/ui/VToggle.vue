<template>
  <div :title="title">
    <label class="switch-lock">
      <input
        v-model="checked"
        type="checkbox"
        @click="emit('click', checked)"
      />
      <span />
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
    default: '#9ccc65'
  },

  offColor: {
    type: String,
    default: '#F44336'
  },

  title: {
    type: String,
    default: 'Lock / Unlock'
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
$lightGrey: #99a3ba;

.switch-lock {
  height: 26px;
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
      color: $lightGrey;
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
      }
    }
  }
}
</style>
