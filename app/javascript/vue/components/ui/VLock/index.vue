<template>
  <div>
    <label
      class="switch-lock"
      v-tooltip="{ content: 'Lock / Unlock', placement: 'bottom' }"
    >
      <input
        :value="value"
        v-model="checked"
        type="checkbox"
      />
      <span>
        <em></em>
        <strong></strong>
      </span>
    </label>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { vTooltip } from '@/directives'
import { useSizes, sizeProps } from '@/composables'

defineOptions({
  name: 'VLock'
})

const props = defineProps({
  ...sizeProps,

  value: {
    type: [String, Boolean],
    required: false
  }
})

const { semanticSize } = useSizes(props)

const lockHeight = computed(() => `var(--size-${semanticSize.value})`)

const checked = defineModel({
  type: [Array, Boolean],
  default: false
})
</script>

<style lang="scss">
$primary: #ffda44;
$lightGrey: #99a3ba;

.switch-lock {
  --switch-lock-height: v-bind(lockHeight);
  --switch-lock-width: calc(var(--switch-lock-height) * 12 / 7);
  --switch-lock-knob-size: calc(var(--switch-lock-height) - 4px);
  --switch-lock-travel: calc(
    var(--switch-lock-width) - var(--switch-lock-knob-size) - 4px
  );

  user-select: none;
  height: var(--switch-lock-height);
  display: block;
  position: relative;
  cursor: pointer;
  input {
    display: none;
    & + span {
      padding-left: calc(var(--switch-lock-width) + 2px);
      min-height: var(--switch-lock-height);
      line-height: var(--switch-lock-height);
      display: block;
      color: var(--text-color);
      position: relative;
      vertical-align: middle;
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
        width: var(--switch-lock-width);
        height: var(--switch-lock-height);
        border-radius: calc(var(--switch-lock-height) / 2);
        background: var(--bg-color);
        transition: all 0.3s ease;
      }
      &:after {
        width: var(--switch-lock-knob-size);
        height: var(--switch-lock-knob-size);
        border-radius: 50%;
        background: var(--panel-bg-color);
        top: 2px;
        left: 2px;
        box-shadow: 0 1px 3px rgba(#121621, 0.1);
        transition: all 0.45s ease;
      }
      em {
        /* The padlock glyph is a fixed 8x12px drawing, centered on the knob */
        width: 8px;
        height: 7px;
        background: var(--text-color);
        opacity: 0.7;
        position: absolute;
        left: calc(2px + (var(--switch-lock-knob-size) - 8px) / 2);
        bottom: calc((var(--switch-lock-height) - 12px) / 2);
        border-radius: var(--border-radius-xsmall);
        display: block;
        z-index: 1;
        transition: all 0.45s ease;
        &:before {
          content: '';
          width: 2px;
          height: 2px;
          border-radius: 1px;
          background: var(--panel-bg-color);
          position: absolute;
          display: block;
          left: 50%;
          top: 50%;
          margin: -1px 0 0 -1px;
        }
        &:after {
          content: '';
          display: block;
          border-top-left-radius: 4px;
          border-top-right-radius: 4px;
          border: 1px solid var(--text-color);
          border-bottom: 0;
          width: 5px;
          height: 4px;
          left: 1px;
          bottom: 6px;
          position: absolute;
          z-index: 1;
          transform-origin: 0 100%;
          transition: all 0.45s ease;
          transform: rotate(-35deg) translate(0, 1px);
        }
      }
      strong {
        font-weight: normal;
        position: relative;
        display: block;
        top: 1px;
        &:before,
        &:after {
          font-size: 14px;
          font-weight: 500;
          display: block;
          font-family: Arial;
          -webkit-backface-visibility: hidden;
        }
        &:before {
          content: '';
          transition: all 0.3s ease 0.2s;
        }
        &:after {
          content: '';
          opacity: 0;
          visibility: hidden;
          position: absolute;
          left: 0;
          top: 0;
          color: var(--color-toggle-active);
          transition: all 0.3s ease;
          transform: translate(2px, 0);
        }
      }
    }
    &:checked {
      & + span {
        &:before {
          background: var(--color-toggle-active);
        }
        &:after {
          background: var(--panel-bg-color);
          transform: translate(var(--switch-lock-travel), 0);
        }
        em {
          transform: translate(var(--switch-lock-travel), 0);
          &:after {
            transform: rotate(0deg) translate(0px, 0);
          }
        }
        strong {
          &:before {
            opacity: 0;
            visibility: hidden;
            transition: all 0.3s ease;
            transform: translate(-2px, 0);
          }
          &:after {
            opacity: 1;
            visibility: visible;
            transform: translate(0, 0);
            transition: all 0.3s ease 0.2s;
          }
        }
      }
    }
  }
}
</style>
