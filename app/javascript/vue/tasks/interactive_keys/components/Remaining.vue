<template>
  <div>
    <h2>Remaining</h2>
    <ul>
      <li
        v-for="item in remaining"
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
    remaining () {
      return this.observationMatrix ? this.observationMatrix.remaining : []
    }
  }
}
</script>
