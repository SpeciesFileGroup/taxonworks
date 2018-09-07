<template>
  <table>
    <tr>
      <th>Pages</th>
      <th>Otu</th>
      <th>Radial</th>
      <th>Otu</th>
    </tr>
    <row-components 
      v-for="item in list"
      :citation="item"/>
  </table>  
</template>

<script>

import RowComponents from './row_components'

export default {
  components: {
    RowComponents
  },
  props: {
    list: {
      type: Array,
      required: true
    }
  }
}
</script>
