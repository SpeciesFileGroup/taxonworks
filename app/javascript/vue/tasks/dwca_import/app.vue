<template>
  <div>
    <div class="flex-separate middle">
      <h1>DwC-A Workbench</h1>
      <ul class="context-menu">
        <li
          v-for="{ label, url } in TASK_LINKS"
          :key="url"
        >
          <a :href="url">{{ label }}</a>
        </li>
      </ul>
    </div>
    <template v-if="dataset.id">
      <div class="position-relative">
        <VNavbar />
        <RequestImport />
        <VTable v-if="!Object.keys(disableStatus).includes(dataset.status)" />
      </div>
      <import-running />
    </template>
    <template v-else>
      <NewImport @on-create="loadDataset($event.id)" />
      <ImportList @on-select="loadDataset" />
    </template>
  </div>
</template>

<script setup>
import NewImport from './components/NewImport'
import ImportList from './components/ImportList'
import VTable from './components/table'
import VNavbar from './components/NavBar'
import ImportRunning from './components/ImportRunning'
import RequestImport from './components/RequestImport'
import { RouteNames } from '@/routes/routes'
import { GetterNames } from './store/getters/getters'
import { MutationNames } from './store/mutations/mutations'
import { ActionNames } from './store/actions/actions'
import { disableStatus } from './const/datasetStatus'
import { computed, onMounted } from 'vue'
import { useStore } from 'vuex'

defineOptions({
  name: 'DWCImporter'
})

const TASK_LINKS = [
  {
    label: 'New namespace',
    url: RouteNames.NewNamespace
  },
  {
    label: 'Manage controlled vocabulary term',
    url: RouteNames.ManageControlledVocabularyTask
  }
]

const store = useStore()

const dataset = computed(() => store.getters[GetterNames.GetDataset])

const pagination = computed({
  get() {
    return store.getters[GetterNames.GetPagination]
  },
  set(value) {
    store.commit(MutationNames.SetPagination, value)
  }
})

onMounted(() => {
  const ID = new URLSearchParams(window.location.search).get(
    'import_dataset_id'
  )
  if (ID) {
    loadDataset(ID)
  }
  document.addEventListener('turbolinks:load', () => {
    window.removeEventListener('scroll', checkScroll)
  })
  window.addEventListener('scroll', checkScroll)
})

function loadDataset(id) {
  store.dispatch(ActionNames.LoadDataset, id).then(() => {
    store.dispatch(ActionNames.LoadDatasetRecords)
  })
}

function checkScroll() {
  const bottomOfTable =
    document.documentElement.scrollTop + window.innerHeight >=
    document.documentElement.offsetHeight

  if (bottomOfTable && dataset.value.id) {
    if (
      pagination.value?.nextPage &&
      pagination.value.nextPage > pagination.value.paginationPage
    ) {
      store.dispatch(ActionNames.LoadDatasetRecords, pagination.value.nextPage)
    }
  }
}
</script>
<style lang="scss">
#vue-task-dwca-import-new {
  .column-filter {
    .filter-container {
      min-width: 200px;
      left: 0;
      position: absolute;
    }
    .vue-autocomplete-input {
      width: 200px;
    }
  }

  .modal-mask {
    z-index: 2102;
  }
}

.dwc-table-help {
  font-weight: normal;

  td {
    color: initial;
  }
}
</style>
