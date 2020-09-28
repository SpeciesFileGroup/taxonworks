<template>
  <div>
    <h2>Eliminated</h2>
    <ul>
      <li
        v-for="item in eliminated"
        :key="item.id"
        v-html="item.object_tag"/>
    </ul>
  </div>
</template>

<script>

import ExtendResult from './extendResult'

export default {
  mixins: [ExtendResult],
  computed: {
    eliminated () {
      return this.observationMatrix ? this.observationMatrix.eliminated : []
    }
  }
}
</script>