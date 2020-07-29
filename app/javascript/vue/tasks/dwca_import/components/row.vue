<template>
  <tr>
    <td>
      <input
        v-model="selectedIds"
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
      @update="updateRecord"/>
  </tr>
</template>

<script>

import ImportRowState from './ImportRowState'
import CellComponent from './Cell'
import { ActionNames } from '../store/actions/actions'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

export default {
  components: {
    CellComponent,
    ImportRowState
  },
  props: {
    row: {
      type: Object,
      required: true
    }
  },
  computed: {
    selectedIds: {
      get () {
        return this.$store.getters[GetterNames.GetSelectedRowIds]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSelectedRowIds, value)
      }
    },
    isReady () {
      return this.row.status === 'Ready'
    }
  },
  methods: {
    updateRecord (data) {
      this.$store.dispatch(ActionNames.UpdateRow, { rowId: this.row.id, data_fields: JSON.stringify(data) })
    }
  }
}
</script>
