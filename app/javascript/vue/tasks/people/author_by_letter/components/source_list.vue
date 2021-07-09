<template>
  <div>
    <table id="source-table">
      <tr>
        <th>Source</th>
        <th/>
      </tr>
      <source-row-component
        v-for="src in list"
        :key="src.id"
        :source="src"/>
    </table>
    <span v-if="list.length">
      {{ list.length }} sources
    </span>
  </div>
</template>
<script>
import SourceRowComponent from './source_row_component'

export default {
  components: {
    SourceRowComponent
  },

  props: {
    list: {
      type: Array,
      required: true
    }
  }
}
</script>
