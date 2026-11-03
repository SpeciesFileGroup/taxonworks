<template>
  <table>
    <thead>
      <tr>
        <th class="w-2">
          <ButtonUnify
            :ids="selected"
            :model="OTU"
          />
        </th>
        <th @click="sortTable('object_label')">Otu</th>
        <th>Depictions</th>
        <th />
      </tr>
    </thead>
    <TableOtuRow
      v-for="item in list"
      :key="item.id"
      :otu="item"
      :depictions="depictionsByOtu[item.id]"
      v-model="selected"
    />
  </table>
</template>

<script setup>
import ButtonUnify from '@/components/ui/Button/ButtonUnify.vue'
import TableOtuRow from './TableOtuRow.vue'
import { ActionNames } from '../../store/actions/actions'
import { useStore } from 'vuex'
import { ref, watch } from 'vue'
import { OTU } from '@/constants'

const props = defineProps({
  list: {
    type: Array,
    required: true
  },

  depictionsByOtu: {
    type: Object,
    default: () => ({})
  }
})

const store = useStore()
const asc = ref(true)
const selected = ref([])

const sortTable = (property) => {
  store.dispatch(ActionNames.SortOtuList, {
    ascending: asc.value,
    property
  })

  asc.value = !asc.value
}

watch(
  () => props.list,
  () => (selected.value = [])
)
</script>
