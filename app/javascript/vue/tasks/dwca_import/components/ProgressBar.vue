<template>
  <div class="progress-bar horizontal-left-content">
    <div
      v-for="(value, key) in progress"
      :key="key"
      :style="{ backgroundColor: colors[key], width: `${getPorcent(progress.Imported)}%` }"/>
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
    getPorcent (count) {
      return count ? count * 100 / this.totalCount : 0
    }
  }
}
</script>
