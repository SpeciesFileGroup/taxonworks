<template>
  <div title="Lock / Unlock">
    <label class="switch-lock">
      <input
        v-model="checked"
        type="checkbox"
      >
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
  }
})

const emit = defineEmits(['update:modelValue'])

const checked = computed({
  get () {
    return props.modelValue
  },
  set (value) {
    emit('update:modelValue', value)
  }
})
</script>
<style lang="scss" scoped>

$lightGrey: #99A3BA;

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
      transition: color .3s ease;
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
        transition: all .3s ease;
      }
      &:after {
        width: 24px;
        height: 24px;
        background: #fff;
        top: 2px;
        left: 3px;
        box-shadow: 0 1px 3px rgba(#121621, .1);
        transition: all .45s ease;
      }
    }
    &:checked {
      & + span {
        &:before {
          background: v-bind('props.onColor');
        }
        &:after {
          background: #fff;
          transform: translate(18px, 0);
        }
      }
    }
  }
}
</style>
