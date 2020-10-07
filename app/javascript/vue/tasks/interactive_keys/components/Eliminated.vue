<template>
  <div>
    <h2>Eliminated ({{ eliminated.length }})</h2>
    <ul>
      <li
        v-for="item in eliminated"
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
    eliminated () {
      return this.observationMatrix ? this.observationMatrix.eliminated : []
    }
  },
  data () {
    return {
      showModal: false
    }
  }
}
</script>