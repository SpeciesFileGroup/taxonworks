<template>
  <div>
    <h2>Created imports</h2>
    <div class="horizontal-left-content">
      <div
        v-for="item in imports"
        :key="item.id"
        class="panel content margin-medium-right margin-medium-bottom cursor-pointer import-card"
        @click="$emit('onSelect', item.id)">
        <h3>{{ item.description }}</h3>
        <span class="subtle">{{ item.type }}</span>
        <hr class="line full_width">

        <ul class="no_bullets">
          <li
            class="flex-separate"
            v-for="(property) in Object.keys(item.progress).sort()"
            :key="property">
            {{ property }}: <b :class="colors[property]">{{ item.progress[property] }}</b>
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script>

import { GetImports } from '../request/resources'

export default {
  data () {
    return {
      imports: [],
      colors: {
        Errored: 'red',
        Imported: 'green',
        Unsupported: 'brown'
      }
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
  min-width: 200px;
}
</style>
