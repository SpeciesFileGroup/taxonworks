<template>
  <classification-list
    :lists="objectLists"
    @select="emit('select', $event)"
  />
</template>

<script setup>
import { GetterNames } from '../../store/getters/getters'
import { createStatusLists } from '../../helpers/createStatusLists'
import { ref, computed, watch } from 'vue'
import { useStore } from 'vuex'
import ClassificationList from './ClassificationList.vue'

const emit = defineEmits(['select'])

const store = useStore()

const statusList = computed(() => store.getters[GetterNames.GetStatusList])
const parent = computed(() => store.getters[GetterNames.GetParent])
const taxon = computed(() => store.getters[GetterNames.GetTaxon])
const taxonRank = computed(() => store.getters[GetterNames.GetRankClass])
const nomenclaturalCode = computed(() => store.getters[GetterNames.GetNomenclaturalCode])

const objectLists = ref({
  tree: [],
  common: [],
  all: []
})

watch([taxonRank, parent],
  () => {
    if (taxon.value && parent.value) {
      objectLists.value = createStatusLists(
        statusList.value[nomenclaturalCode.value] || {},
        taxon.value.rank_string,
        parent.value.rank_string
      )
    }
  },
  { immediate: true })

</script>
