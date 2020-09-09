<template>
  <ul class="no_bullets">
    <template v-if="tableMode">
      <li
        style="border-bottom: 1px solid #EAEAEA"
        class="flex-separate padding-small"
        v-for="(color, property) in colors"
        :key="property">
        <span>{{ property }}</span> <b :style="{ color: color }">{{ showTotal(progress[property]) }}</b>
      </li>
    </template>
    <template v-else>
      <li
        class="flex-separate"
        v-for="(color, property) in colors"
        :key="property">
        <span>{{ property }}: <b :style="{ color: color }">{{ showTotal(progress[property]) }}</b></span>
      </li>
    </template>
  </ul>
</template>

<script>

import ImportColors from '../const/importColors.js'

export default {
  props: {
    progress: {
      type: Object,
      required: true
    },
    tableMode: {
      type: Boolean,
      default: false
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
