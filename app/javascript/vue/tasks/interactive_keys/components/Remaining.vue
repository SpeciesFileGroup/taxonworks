<template>
  <div>
    <spinner-component
      v-if="isLoading"
      legend="Loading..." />
    <div class="flex-separate middle">
      <h2>Remaining ({{ remaining.length }})</h2>
      <row-filter/>
    </div>
    <ul>
      <li
        class="margin-small-bottom"
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
import RowFilter from './RowFilter'

export default {
  mixins: [ExtendResult],
  components: {
    RowComponent,
    RowFilter
  },
  computed: {
    remaining () {
      return this.observationMatrix ? this.observationMatrix.remaining : []
    }
  }
}
</script>
