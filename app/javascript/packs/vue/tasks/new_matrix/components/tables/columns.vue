<template>
  <div>
    <table-list
      :list="list"
      :destroy="true"
      @delete="removeRow"
      :header="['name', 'current matches', '']"
      :attributes="[['descriptor','object_tag'], 'row_object_label']"/>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import ActionNames from '../../store/actions/actionNames'
import tableList from '../../../../components/table_list.vue'

export default {
  components: {
    tableList
  },
  computed: {
    list() {
      return this.$store.getters[GetterNames.GetMatrixColumns]
    }
  },
  methods: {
    removeRow(column) {
      this.$store.dispatch(ActionNames.RemoveColumn, column.id)
    }
  }
}
</script>