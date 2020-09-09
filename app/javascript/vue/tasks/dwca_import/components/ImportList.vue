<template>
  <div v-if="imports.length">
    <h2>Created imports</h2>
    <div class="flex-wrap-row">
      <div
        v-for="item in imports"
        :key="item.id"
        class="panel content margin-medium-right margin-medium-bottom cursor-pointer import-card"
        @click="$emit('onSelect', item.id)">
        <h3><b>{{ item.description }}</b></h3>
        <span>DwC-A {{ item.type.split('::').pop() }}</span>
        <hr class="line full_width">
        <progress-bar
          class="full_width"
          :progress="item.progress"/>
        <progress-list
          class="no_bullets"
          :progress="item.progress"/>
      </div>
    </div>
  </div>
</template>

<script>

import { GetImports } from '../request/resources.js'
import ProgressBar from './ProgressBar.vue'
import ProgressList from './ProgressList'

export default {
  components: {
    ProgressBar,
    ProgressList
  },
  data () {
    return {
      imports: []
    }
  },
  mounted () {
    GetImports().then((response) => {
      this.imports = response.body
    })
  }
}
</script>

<style scoped>
.import-card {
  min-width: 300px;
}
</style>
