<template>
  <tr>
    <cell-component
      v-for="(cell, index) in row"
      :cell="cell"/>
  </tr>
</template>

<script>

import CellComponent from './Cell'

export default {
  components: {
    CellComponent
  },
  props: {
    row: {
      type: Array,
      required: true
    }
  }
}
</script>
