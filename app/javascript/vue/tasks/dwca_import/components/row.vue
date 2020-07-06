<template>
  <tr>
    <td>
      <input
        v-model="ids"
        :disabled="!isReady"
        :value="row.id"
        type="checkbox">
    </td>
    <import-row-state :row="row"/>
    <cell-component
      v-for="(data_field, index) in row.data_fields"
      :key="index"
      :cell="data_field.value"
      :cell-index="index"
      :import-id="importId"
      @update="updateRecord"/>
  </tr>
</template>

<script>

import ImportRowState from './ImportRowState'
import CellComponent from './Cell'
import { UpdateRow } from '../request/resources'

export default {
  components: {
    CellComponent,
    ImportRowState
  },
  props: {
    row: {
      type: Object,
      required: true
    },
    importId: {
      type: [String, Number],
      required: true
    },
    value: {
      type: Array,
      required: true
    }
  },
  computed: {
    ids: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    },
    isReady () {
      return this.row.status === 'Ready'
    }
  },
  methods: {
    updateRecord (data) {
      UpdateRow(this.importId, this.row.id, { data_fields: JSON.stringify(data) })
    }
  }
}
</script>
