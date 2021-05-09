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
    <g :fill="color">
      <path
        v-for="(path, index) in iconPaths"
        :key="index"
        :d="path.d"
      />
    </g>
  </svg>
</template>

<script>

import colors from 'assets/styles/variables/_palette.scss'
import { convertToUnit } from 'helpers/style'
import { Icons } from './icons.js'

const SIZE_MAP = {
  xSmall: '12px',
  small: '16px',
  default: '24px',
  medium: '28px',
  large: '36px',
  xLarge: '40px'
}

export default {
  props: {
    xSmall: {
      type: Boolean,
      default: false
    },

    small: {
      type: Boolean,
      default: false
    },

    medium: {
      type: Boolean,
      default: false
    },

    large: {
      type: Boolean,
      default: false
    },

    xLarge: {
      type: Boolean,
      default: false
    },

    disabled: {
      type: Boolean,
      default: false
    },

    name: {
      type: String,
      required: true
    },

    size: {
      type: [Number, String],
      default: SIZE_MAP.default
    },

    color: {
      type: String,
      default: 'currentColor'
    }
  },

  data () {
    return {
      colors
    }
  },

  computed: {
    isComponentExist () {
      return this.$options.components[this.iconName]
    },

    iconPaths () {
      return Icons[this.name]?.paths || []
    },

    iconSize () {
      const sizes = {
        xSmall: this.xSmall,
        small: this.small,
        medium: this.medium,
        large: this.large,
        xLarge: this.xLarge
      }

      const explicitSize = Object.keys(sizes).find(key => sizes[key])

      return (explicitSize && SIZE_MAP[explicitSize]) || convertToUnit(this.size)
    }
  },

  created () {
    console.log(colors)
  }
}
</script>
