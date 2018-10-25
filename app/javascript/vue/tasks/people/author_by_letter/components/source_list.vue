<template>
  <div class="flex-separate">
    <table id="source-table">
      <tr>
        <th>Source</th>
        <th/>
        <th/>
      </tr>
      <source-row-component
        v-for="src in list"
        :key="src.id"
        :source="src"/>
    </table>
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
      },
    }
  }
</script>
