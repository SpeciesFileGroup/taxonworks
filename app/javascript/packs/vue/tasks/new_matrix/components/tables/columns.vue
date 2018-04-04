<template>
  <div>
    <table-list
      :list="list"
      :destroy="true"
      :header="['name', 'current matches', '']"
      :attributes="[['descriptor','object_tag'], 'row_object_label']"/>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
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
  data() {
    return {

    }
  },
}
</script>