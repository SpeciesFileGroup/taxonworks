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
      :fill="selectedColor">
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
      return this.title || `${this.name} icon`
    }
  },

  watch: {
    name: {
      handler () {
        this.viewbox = this.getViewboxSize()
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

        return [groupSize.x, groupSize.y, groupSize.width, groupSize.height].join(' ')
      } else {
        return '0 0 12 12'
      }
    }
  }
}
</script>
