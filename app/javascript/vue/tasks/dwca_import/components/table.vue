<template>
  <table>
    <thead>
      <tr>
        <th 
          v-for="(item, index) in table.headers"
          :key="index">
          {{ item }}
        </th>
      </tr>
    </thead>
    <tbody>
      <row-component 
        v-for="row in table.rows"
        :row="row"/>
    </tbody>
  </table>
</template>

<script>

import RowComponent from './row'

export default {
  components: {
    RowComponent
  },
  props: {
    table: {
      type: Object,
      required: true
    }
  }
}
</script>

<style>

</style>