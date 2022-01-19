<template>
  <div>
    <switch-component
      v-model="view"
      :options="Object.values(TAB)"
    />

    <component
      :is="ListComponents[view]"
      :list="objectLists"
      :created="statusCreated" />

    <ul
      v-if="!statusCreated.length && taxon.cached_is_valid"
      class="table-entrys-list">
      <li class="list-complete-item middle">
        <p>Valid as default</p>
      </li>
    </ul>

    <list-entrys
      @update="loadTaxonStatus"
      @add-citation="setCitation"
      @delete="removeStatus"
      :edit="true"
      :list="statusCreated"
      :display="['object_tag']"
    />
  </div>
</template>

<script setup>
import { GetterNames } from '../../../store/getters/getters'
import { createStatusLists } from '../../../helpers/createStatusLists'
import { TaxonNameClassification } from 'routes/endpoints'
import { ref, computed, watch } from 'vue'
import { useStore } from 'vuex'

import ListEntrys from '../../listEntrys.vue'
import SwitchComponent from 'components/switch'

const store = useStore()


const TAB = {
  common: 'Common',
  advanced: 'Advanced',
  showAll: 'Show all'
}

const ListComponents = {
  [TAB.common]: import('./ClassificationCommon.vue'),
  [TAB.advanced]: import('./ClassificationAdvanced.vue'),
  [TAB.showAll]: import('./ClassificationAdvanced.vue')
}

const view = ref(TAB.common)

const objectLists = ref({
  tree: [],
  common: [],
  all: []
})

const statusList = computed(() => store.getters[GetterNames.GetStatusList])
const statusCreated = ref([])

const createStatus = item => {}

const removeStatus = item => { TaxonNameClassification.destroy(item.id) }

const parent = computed(() => store.getters[GetterNames.GetParent])
const taxon = computed(() => store.getters[GetterNames.GetTaxon])
const taxonRank = computed(() => store.getters[GetterNames.GetRankClass])
const nomenclaturalCode = computed(() => store.getters[GetterNames.GetNomenclaturalCode])

const refreshLists = () => {
  const list = statusList.value[nomenclaturalCode.value] || {}

  objectLists.value = createStatusLists(list, this.taxon.rank_string, this.parent.rank_string)
}

watch([taxonRank, parent], () => {
  refreshLists()
}, { immediate: true })

</script>
