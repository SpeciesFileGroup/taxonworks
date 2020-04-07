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
        v-for="(row, index) in table.rows"
        class="contextMenuCells"
        :class="{ 'even': (index % 2 == 0) }"
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