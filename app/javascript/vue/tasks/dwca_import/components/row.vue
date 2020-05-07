<template>
  <tr>
    <cell-component
      :disabled="true"
      :cell="row.status"/>
    <cell-component
      v-for="(header, index) in headers"
      :cell="row.data_fields[header].value"
      :import-id="importId"
      :attribute="header"
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
    headers: {
      type: Array,
      required: true
    },
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
