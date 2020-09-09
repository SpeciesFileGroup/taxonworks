<template>
  <ul class="no_bullets">
    <li
      class="flex-separate"
      v-for="(color, property) in colors"
      :key="property">
      <span>{{ property }}: <b :style="{ color: color }">{{ showTotal(progress[property]) }}</b></span>
    </li>
  </ul>
</template>

<script>

import ImportColors from '../const/importColors.js'

export default {
  props: {
    progress: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      colors: ImportColors
    }
  },
  methods: {
    showTotal (count = 0) {
      return count
    }
  }
}
</script>
