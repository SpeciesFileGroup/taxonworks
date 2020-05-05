<template>
  <tr>
    <cell-component
      :cell="row.status"/>
    <cell-component
      v-for="(header, index) in headers"
      :cell="row.data_fields[header].value"/>
  </tr>
</template>

<script>

import CellComponent from './Cell'

export default {
  components: {
    CellComponent
  },
  props: {
    headers: {
      type: Array,
      required: true
    },
    row: {
      type: Object,
      required: true
    }
  }
}
</script>
