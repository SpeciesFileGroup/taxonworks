<template>
  <span
    v-if="disabled"
    class="v-btn-tippy-wrapper"
    v-tooltip="tooltipOptions"
  >
    <component
      :is="tag"
      v-bind="buttonAttributes"
      type="button"
      :aria-label="title"
      @click="$emit('click', $event)"
    >
      <slot />
    </component>
  </span>

  <component
    v-else
    :is="tag"
    v-bind="buttonAttributes"
    type="button"
    :aria-label="title"
    v-tooltip="tooltipOptions"
    @click="$emit('click', $event)"
  >
    <slot />
  </component>
</template>

<script>
import { vTooltip } from '@/directives'
import mixinSizes from '../mixins/sizes.js'
import mixinColor from '../mixins/colors.js'

export default {
  name: 'VBtn',

  directives: {
    tooltip: vTooltip
  },

  mixins: [mixinSizes, mixinColor],

  props: {
    disabled: {
      type: Boolean,
      default: false
    },

    download: {
      type: [String, Boolean],
      default: undefined
    },

    href: {
      type: String,
      default: undefined
    },

    circle: {
      type: Boolean,
      default: false
    },

    pill: {
      type: Boolean,
      default: false
    },

    color: {
      type: String,
      default: 'default'
    },

    title: {
      type: String,
      default: ''
    }
  },

  emits: ['click'],

  computed: {
    tag() {
      return this.href ? 'a' : 'button'
    },

    buttonSize() {
      return this.circle
        ? `btn-${this.semanticSize}-circle`
        : `btn-${this.semanticSize}-size`
    },

    buttonClasses() {
      const isLink = !!this.href

      return [
        'button',
        `btn-${this.color}`,
        isLink ? 'btn-link' : 'btn',
        this.buttonSize
      ]
    },

    buttonAttributes() {
      return {
        class: this.buttonClasses,
        disabled: this.disabled,
        download: this.download,
        href: this.href
      }
    },

    tooltipOptions() {
      return {
        content: this.title,
        placement: 'bottom'
      }
    }
  }
}
</script>

<style scoped>
.v-btn-tippy-wrapper {
  display: inline-flex;
}
</style>
