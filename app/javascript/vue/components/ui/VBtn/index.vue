<template>
  <component
    :is="tag"
    :class="buttonClasses"
    :disabled="disabled"
    :download="download"
    :href="href"
    type="button"
    @click="$emit('click')"
  >
    <slot />
  </component>
</template>

<script>

import mixinSizes from '../mixins/sizes.js'
import mixinColor from '../mixins/colors.js'

export default {
  name: 'VBtn',

  mixins: [
    mixinSizes,
    mixinColor
  ],

  props: {
    disabled: {
      type: Boolean,
      default: false
    },

    download: {
      type: [Boolean, String],
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

  emits: ['click'],

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
        'button',
        `btn-${this.color}`
      ]
    }
  }
}

</script>
