<template>
  <ul class="no_bullets">
    <li
      class="flex-separate"
      v-for="(value, property) in progress"
      :key="property">
      <span>{{ property }}: <b :class="colors[property]">{{ value }}</b></span>
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
  }
}
</script>
