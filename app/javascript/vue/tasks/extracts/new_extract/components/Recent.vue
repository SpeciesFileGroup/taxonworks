<template>
  <div>
    <table-list
      :header="['Extract', '']"
      :attributes="['object_tag']"
      :list="list"
      edit
      @edit="loadExtract"
      @delete="removeRecent"
    />
  </div>
</template>

<script>

import { ActionNames } from '../store/actions/actions'
import { GetterNames } from '../store/getters/getters'
import TableList from 'components/table_list'

export default {
  components: { TableList },

  computed: {
    list () {
      return this.$store.getters[GetterNames.GetRecent]
    }
  },

  created () {
    this.$store.dispatch(ActionNames.LoadRecents)
  },

  methods: {
    removeRecent (extract) {
      this.$store.dispatch(ActionNames.RemoveExtract, extract)
    },

    loadExtract ({ id }) {
      this.$store.dispatch(ActionNames.LoadExtract, id)
    }
  }
}
</script>
