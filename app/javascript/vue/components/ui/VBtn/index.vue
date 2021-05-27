<template>
  <component
    :is="isLink ? 'a' : 'button'"
    type="button">
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
    }
  },

  computed: {
    isLink () {
      return !!this.href
    }
  }
}

</script>
<style scoped>

</style>
