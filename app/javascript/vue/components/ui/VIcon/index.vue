<template>
  <svg
    xmlns="http://www.w3.org/2000/svg"
    :width="elementSize"
    :height="elementSize"
    :viewBox="viewbox"
    :aria-labelledby="name"
    role="presentation"
  >
    <title
      :id="name"
      lang="en"
    >
      {{ showTitle }}
    </title>
    <g
      ref="svggroup"
      stroke-width="2"
      :fill="selectedColor"
    >
      <path
        v-for="(path, index) in iconPaths"
        :key="index"
        v-bind="path"
      />
    </g>
  </svg>
</template>

<script>

import mixinSizes from '../mixins/sizes.js'
import mixinColors from '../mixins/colors.js'
import * as Icons from './icons.js'

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
    },

    title: {
      type: String,
      default: undefined
    }
  },

  data () {
    return {
      viewbox: '0 0 12 12'
    }
  },

  computed: {
    iconPaths () {
      return Icons[this.name]?.paths || []
    },

    showTitle () {
      return this.title
    }
  },

  watch: {
    name: {
      handler () {
        this.$nextTick(() => {
          this.viewbox = this.getViewboxSize()
        })
      }
    }
  },

  mounted () {
    this.$nextTick(() => {
      this.viewbox = this.getViewboxSize()
    })
  },

  methods: {
    getViewboxSize () {
      const refGroup = this.$refs.svggroup

      if (refGroup) {
        const groupSize = refGroup.getBBox()
        const strokePaths = this.iconPaths.map(path => path['stroke-width']).filter(stroke => stroke)
        const strokeWidth = strokePaths.length
          ? Math.max(...strokePaths)
          : 0

        return [
          groupSize.x - strokeWidth / 2,
          groupSize.y - strokeWidth / 2,
          groupSize.width + strokeWidth,
          groupSize.height + strokeWidth
        ].join(' ')
      } else {
        return '0 0 12 12'
      }
    }
  }
}
</script>
