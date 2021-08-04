<template>
  <div ref="radialContainer" />
</template>

<script>

import RadialMenu from '@sfgrp/svg-radial-menu'

export default {
  props: {
    options: {
      type: Object,
      required: true
    }
  },

  data () {
    return {
      radialInstance: undefined
    }
  },

  watch: {
    options: {
      handler (newVal) {
        if (!newVal) return
        this.init()
      }
    }
  },

  mounted () {
    this.init()
  },

  methods: {
    init () {
      const element = this.$refs.radialContainer

      this.radialInstance = new RadialMenu(element, this.options)
      this.handleEvents()
    },

    handleEvents () {
      this.radialInstance.on('click', (event) => this.$emit('onClick', event))
    }
  }
}
</script>
