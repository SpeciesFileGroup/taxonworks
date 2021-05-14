<template>
  <component
    :is="isLink ? 'a' : 'button'"
    type="button">
    <slot />
  </component>
</template>

<script>

export default {
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
