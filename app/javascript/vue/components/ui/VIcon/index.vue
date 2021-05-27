<template>
  <svg
    xmlns="http://www.w3.org/2000/svg"
    :width="iconSize"
    :height="iconSize"
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

import paletteColors from 'assets/styles/variables/_exports.scss'
import mixinSizes from '../mixins/sizes.js'
import { Icons } from './icons.js'

export default {
  mixins: [mixinSizes],

  props: {
    disabled: {
      type: Boolean,
      default: false
    },

    name: {
      type: String,
      required: true
    },

    color: {
      type: String,
      default: 'currentColor'
    }
  },

  computed: {
    isComponentExist () {
      return this.$options.components[this.iconName]
    },

    iconPaths () {
      return Icons[this.name]?.paths || []
    },

    selectedColor () {
      return paletteColors[this.color] || this.color
    }
  }
}
</script>
