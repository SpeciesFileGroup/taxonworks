<template>
  <tr>
    <cell-component
      :disabled="true"
      :cell="row.status"/>
    <cell-component
      v-for="(data_field, index) in row.data_fields"
      :cell="data_field.value"
      :cell-index="index"
      :import-id="importId"
      @update="updateRecord"/>
  </tr>
</template>

<script>

import CellComponent from './Cell'
import { UpdateRow } from '../request/resources'

export default {
  components: {
    CellComponent
  },
  props: {
    row: {
      type: Object,
      required: true
    },
    importId: {
      type: [String, Number],
      required: true
    }
  },
  methods: {
    updateRecord (data) {
      UpdateRow(this.importId, this.row.id, { data_fields: JSON.stringify(data) })
    }
  }
}
</script>
