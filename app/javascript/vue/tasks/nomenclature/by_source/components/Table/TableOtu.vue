<template>
  <table>
    <tr>
      <th @click="sortTable('object_label')">Otu</th>
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
import { ActionNames } from '../../store/actions/actions'
import { useStore } from 'vuex'
import { ref } from 'vue'

const props = defineProps({
  list: {
    type: Array,
    required: true
  }
})

const store = useStore()
const asc = ref(true)

const sortTable = property => {
  store.dispatch(ActionNames.SortOtuList, {
    ascending: asc.value,
    property
  })

  asc.value = !asc.value
}
</script>
