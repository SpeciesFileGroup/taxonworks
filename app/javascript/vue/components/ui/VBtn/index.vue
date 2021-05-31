<template>
  <component
    :is="tag"
    :class="buttonClasses"
    :disabled="disabled"
    type="button"
  >
    <slot />
  </component>
</template>

<script>

import mixinSizes from '../mixins/sizes.js'
import mixinColor from '../mixins/colors.js'

export default {
  mixins: [
    mixinSizes,
    mixinColor
  ],

  props: {
    disabled: {
      type: Boolean,
      default: false
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
    }
  },

  computed: {
    tag () {
      return this.href ? 'a' : 'button'
    },

    buttonSize () {
      return this.circle
        ? `btn-${this.semanticSize}-circle`
        : `btn-${this.semanticSize}-size`
    },

    buttonClasses () {
      return [
        this.buttonSize,
        `btn-${this.color}`
      ]
    }
  }
}

</script>
