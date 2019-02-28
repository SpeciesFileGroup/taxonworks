<template>
  <div>
    <table-component
      :header="['Source', 'Options']"
      :attributes="['object_tag']"
      :edit="true"
      @edit="editSource"
      :destroy="false"
      :list="sources"/>
  </div>
</template>

<script>

import { GetRecentSources } from '../request/resources.js'
import TableComponent from 'components/table_list.vue'

export default {
  components: {
    TableComponent
  },
  data() {
    return {
      sources: []
    }
  },
  mounted() {
    GetRecentSources().then(response => {
      this.sources = response.body
    })
  },
  methods: {
    editSource(source) {
      window.open(`/sources/${source.id}/edit`,'blank')
    }
  }
}
</script>
