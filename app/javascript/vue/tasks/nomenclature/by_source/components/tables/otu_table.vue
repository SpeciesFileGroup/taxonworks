<template>
  <table>
    <tr>
      <th>Otu</th>
      <th>Radial</th>
      <th>Otu</th>
    </tr>
    <row-components
        v-for="item in list"
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
