<template>
  <div
    class="progress-bar horizontal-left-content"
    :style="{
      backgroundColor: 'gray',
      height: '10px'
    }">
    <div
      v-for="(value, key) in colors"
      :key="key"
      :style="{
        backgroundColor: value,
        height: '10px',
        width: `${getPorcent(key)}%`
      }"/>
  </div>
</template>

<script>

import ImportColors from '../const/importColors'

export default {
  props: {
    progress: {
      type: Object,
      default: () => { return {} }
    }
  },
  computed: {
    totalCount () {
      return Object.values(this.progress).reduce((accumulator, currentValue) => accumulator + currentValue)
    }
  },
  data () {
    return {
      colors: ImportColors
    }
  },
  methods: {
    getPorcent (key) {
      return this.progress[key] ? this.progress[key] * 100 / this.totalCount : 0
    }
  }
}
</script>
