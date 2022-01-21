<template>
  <div>
    <switch-component
      v-model="currentTab"
      :options="Object.values(TAB)"
    />

    <component
      :is="ListComponents[currentTab]"
      :lists="objectLists"
      :created="statusCreated"
      @close="currentTab = TAB.common"
      @select="createStatus"
    />

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
import { ref, computed, watch, defineAsyncComponent } from 'vue'
import { useStore } from 'vuex'
import ListEntrys from '../../listEntrys.vue'
import SwitchComponent from 'components/switch'

const store = useStore()

const props = defineProps({
  taxonId: {
    type: [String, Number],
    required: true
  }
})

const emit = defineEmits(['create'])

const TAB = {
  common: 'Common',
  advanced: 'Advanced',
  showAll: 'Show all'
}

const ListComponents = {
  [TAB.common]: defineAsyncComponent({ loader: () => import('./ClassificationListCommon.vue') }),
  [TAB.advanced]: defineAsyncComponent({ loader: () => import('./ClassificationListAdvanced.vue') }),
  [TAB.showAll]: defineAsyncComponent({ loader: () => import('./ClassificationListAll.vue') })
}

const currentTab = ref(TAB.common)

const statusList = computed(() => store.getters[GetterNames.GetStatusList])
const statusCreated = ref([])

const createStatus = ({ type }) => {
  emit('create', {
    taxon_name_id: props.taxonId,
    type
  })
}

const removeStatus = item => { TaxonNameClassification.destroy(item.id) }

const parent = computed(() => store.getters[GetterNames.GetParent])
const taxon = computed(() => store.getters[GetterNames.GetTaxon])
const taxonRank = computed(() => store.getters[GetterNames.GetRankClass])
const nomenclaturalCode = computed(() => store.getters[GetterNames.GetNomenclaturalCode])

const objectLists = ref({
  tree: [],
  common: [],
  all: []
})

watch([taxonRank, parent], () => {
  objectLists.value = createStatusLists(
    statusList.value[nomenclaturalCode.value] || {},
    taxon.value.rank_string,
    parent.value.rank_string
  )
}, { immediate: true })

watch(() => props.taxonId, newVal => {
  if (newVal) {
    TaxonNameClassification.where({
      taxon_name_id: props.taxonId
    }).then(({ body }) => {
      statusCreated.value = body
    })
  }
})

</script>
