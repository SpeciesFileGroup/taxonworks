<template>
  <tree-display
    :list="lists.tree"
    :taxon-rank="rankString"
    :filter="created"
    :created-list="created"
    title="Status"
    display-name="name"
    @close="emit('close')"
    @selected="emit('select', $event)"
  />
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters'
import TreeDisplay from '../treeDisplay.vue'

const props = defineProps({
  lists: {
    type: Object,
    required: true
  },

  created: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits([
  'close',
  'select'
])

const store = useStore()

const rankString = computed(() => store.getters[GetterNames.GetTaxon]?.rank_string)

</script>
