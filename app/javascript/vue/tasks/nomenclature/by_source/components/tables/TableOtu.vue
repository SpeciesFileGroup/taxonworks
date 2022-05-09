<template>
  <table>
    <tr>
      <th>Otu</th>
      <th/>
    </tr>
    <TableOtuRow
      v-for="item in list"
      :key="item.id"
      :otu="item"/>
  </table>
</template>

<script setup>
import TableOtuRow from './TableOtuRow.vue'
import { ref } from 'vue'

const props = defineProps({
  list: {
    type: Array,
    required: true
  }
})

const ascending = ref(true)

const sortTable = sortProperty => {}
</script>
