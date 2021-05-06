<template>
  <div class="">
    <h3>Recent</h3>
    <table-list
      :header="['Extract', 'Updated at', '']"
      :attributes="['object_tag', 'updated_at']"
      :list="list"
      edit
      @edit="$emit('onLoad', $event)"
      @delete="$emit('onDelete', $event)"
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

  }
}
</script>
