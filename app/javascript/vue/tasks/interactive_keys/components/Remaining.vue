<template>
  <div>
    <h2>Remaining ({{ remaining.length }})</h2>
    <ul>
      <li
        v-for="item in remaining"
        :key="item.object.id">
        <row-component :row="item"/>
      </li>
    </ul>
  </div>
</template>

<script>

import ExtendResult from './extendResult'
import RowComponent from './Row'

export default {
  mixins: [ExtendResult],
  components: {
    RowComponent
  },
  computed: {
    remaining () {
      return this.observationMatrix ? this.observationMatrix.remaining : []
    }
  }
}
</script>
