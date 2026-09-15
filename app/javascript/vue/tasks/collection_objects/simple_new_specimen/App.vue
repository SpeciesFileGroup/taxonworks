<template>
  <div
    id="vue-simple-new-specimen-container"
    class="gap-medium"
    ref="root"
  >
    <BlockLayout>
      <template #header>
        <h3>Collection object</h3>
      </template>
      <template #body>
        <div id="collection-object-form">
          <div class="flex-col gap-small">
            <FormCatalogNumber />
            <FormPreparationType />
            <FormTotal />
            <FormDetermination />
          </div>
          <div class="flex-col gap-medium">
            <FormDepictions />
            <FormScalebar />
          </div>
        </div>
      </template>
    </BlockLayout>

    <BlockLayout>
      <template #header>
        <h3>Collecting event</h3>
      </template>
      <template #options>
        <VLock v-model="store.settings.lock.collectingEvent" />
      </template>
      <template #body>
        <FormCE />
      </template>
    </BlockLayout>

    <div class="panel create-panel">
      <div class="flex-separate middle gap-medium">
        <FormCreateTotal />
        <VBtn
          class="create-button"
          color="create"
          medium
          @click="store.createNewSpecimen()"
          @keydown.tab.prevent="setFristAutofocusElement"
        >
          Create
        </VBtn>
      </div>
    </div>
  </div>
  <RecentTable />
</template>

<script setup>
import FormCE from './components/FormCE.vue'
import FormPreparationType from './components/FormPreparationType.vue'
import FormCatalogNumber from './components/FormCatalogNumber.vue'
import FormDepictions from './components/FormDepictions.vue'
import FormDetermination from './components/FormDetermination.vue'
import FormCreateTotal from './components/FormCreateTotal.vue'
import FormTotal from './components/FormTotal.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VLock from '@/components/ui/VLock/index.vue'
import RecentTable from './components/RecentTable.vue'
import { useHotkey } from '@/composables'
import platformKey from '@/helpers/getPlatformKey'
import { ref } from 'vue'
import { useStore } from './store/useStore'
import { ActionNames } from './store/actions/actions'
import { GetterNames } from './store/getters/getters'
import FormScalebar from './components/FormScalebar.vue'

const store = useStore()
const root = ref(null)

store[ActionNames.GetRecent]()

const setFristAutofocusElement = () => {
  const element = root.value.querySelector(`
    input[type="text"]:not([disabled], [data-locked="true"]), 
    textarea:not([disabled], [data-locked="true"]), 
    select:not([disabled], [data-locked="true"])`)

  if (!store[GetterNames.IsAllLocked] && element) {
    element.focus()
  }
}

const hotkeys = [
  {
    keys: [platformKey(), 'n'],
    preventDefault: true,
    handler() {
      resetStore()
      setFristAutofocusElement()
    }
  },
  {
    keys: [platformKey(), 's'],
    preventDefault: true,
    handler() {
      store.createNewSpecimen()
    }
  }
]

const stop = useHotkey(hotkeys)
const unsubscribe = store.$onAction(({ name, after }) => {
  if (name !== ActionNames.CreateNewSpecimen) {
    return
  }

  after((_) => {
    setFristAutofocusElement()
  })
})

const resetStore = () => {
  const recent = store.recentList

  store.$reset()
  store.recentList = recent
}

TW.workbench.keyboard.createLegend(
  `${platformKey()}+s`,
  'Save',
  'Simple new specimen'
)
TW.workbench.keyboard.createLegend(
  `${platformKey()}+n`,
  'New',
  'Simple new specimen'
)
</script>

<style lang="scss">
#vue-simple-new-specimen-container {
  display: flex;
  flex-direction: column;
  margin: 0 auto;
  margin-top: 1em;
  max-width: 1240px;

  #collection-object-form {
    display: grid;
    grid-template-columns: repeat(2, minmax(250px, 1fr));
    gap: 1.5em;
    grid-auto-flow: dense;
  }

  .create-panel {
    padding: 1em 1.5em;

    .create-button {
      min-width: 120px;
    }
  }

  hr {
    height: 1px;
    color: #f5f5f5;
    background: #f5f5f5;
    font-size: 0;
    margin: 15px;
    border: 0;
  }
}
</style>
