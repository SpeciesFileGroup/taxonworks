<template>
  <div>
    <table-list
      :list="list"
      :destroy="true"
      @delete="removeRow"
      :header="['name', 'current matches', '']"
      :attributes="['observation_matrix_row_object_label', 'row_object_label']"/>
  </div>
</template>

<script>

import ActionNames from '../../store/actions/actionNames'
import { GetterNames } from '../../store/getters/getters'
import tableList from 'components/table_list.vue'

export default {
  components: {
    tableList
  },
  computed: {
    list() {
      return this.$store.getters[GetterNames.GetMatrixRows]
    }
  },
  methods: {
    removeRow(row) {
      this.$store.dispatch(ActionNames.RemoveRow, row.id)
    }
  }
}
</script>