<template>
  <div>
    <table-list
      :list="list"
      :destroy="true"
      :header="['name', 'current matches', 'remove']"
      :attributes="['row_object_label', 'row_object_label']"  />
  </div>
</template>

<script>

import { MutationNames } from '../../store/mutations/mutations'
import { GetterNames } from '../../store/getters/getters'
import tableList from '../../../../components/table_list.vue'

export default {
  components: {
    tableList
  },
  computed: {
    list() {
      return this.$store.getters[GetterNames.GetMatrixRows]
    }
  },
  data() {
    return {

    }
  },
}
</script>