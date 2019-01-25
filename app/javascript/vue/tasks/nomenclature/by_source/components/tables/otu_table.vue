<template>
  <table>
    <tr>
      <th>Otu</th>
      <th>Radial</th>
      <th>Otu</th>
      <th>Otu navigator</th>
    </tr>
    <otu-row-component
      v-for="item in list"
      :key="item.id"
      :otu="item"/>
  </table>
</template>

<script>

  import OtuRowComponent from './otu_row_component'

  export default {
    components: {
      OtuRowComponent
    },
    props: {
      list: {
        type: Array,
        required: true
      }
    }
  }
</script>
