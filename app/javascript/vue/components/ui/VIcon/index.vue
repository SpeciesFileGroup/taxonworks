<template>
  <svg
    xmlns="http://www.w3.org/2000/svg"
    :width="elementSize"
    :height="elementSize"
    viewBox="0 0 12 12"
    :aria-labelledby="name"
    role="presentation"
  >
    <title
      :id="name"
      lang="en"
    >
      {{ name }} icon
    </title>
    <g :fill="selectedColor">
      <path
        v-for="(path, index) in iconPaths"
        :key="index"
        :d="path.d"
      />
    </g>
  </svg>
</template>

<script>

import mixinSizes from '../mixins/sizes.js'
import mixinColors from '../mixins/colors.js'
import { Icons } from './icons.js'

export default {
  name: 'VIcon',

  mixins: [
    mixinSizes,
    mixinColors
  ],

  props: {
    disabled: {
      type: Boolean,
      default: false
    },

    name: {
      type: String,
      required: true
    }
  },

  computed: {
    iconPaths () {
      return Icons[this.name]?.paths || []
    }
  }
}
</script>
