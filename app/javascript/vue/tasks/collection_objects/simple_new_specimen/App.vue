<template>
  <div id="vue-simple-new-specimen-container">
    <h1>Simple new specimen</h1>
    <BlockLayout>
      <template #header>
        <h3>Information</h3>
      </template>
      <template #body>
        <div
          class="margin-medium-bottom"
          id="collection-object-form"
          ref="root"
        >
          <div>
            <FormCatalogNumber class="margin-medium-bottom" />
            <FormPreparationType class="margin-medium-bottom" />
            <FormDetermination class="margin-medium-bottom" />
            <FormCE />
          </div>
          <FormDepictions />
          <div>
            <VBtn
              color="create"
              medium
              @click="store.createNewSpecimen()"
              @keydown.tab.prevent="setFristAutofocusElement"
            >
              Create
            </VBtn>
          </div>
        </div>
      </template>
    </BlockLayout>
  </div>
  <RecentTable />
</template>

<script setup>
import FormCE from './components/FormCE.vue'
import FormPreparationType from './components/FormPreparationType.vue'
import FormCatalogNumber from './components/FormCatalogNumber.vue'
import FormDepictions from './components/FormDepictions.vue'
import FormDetermination from './components/FormDetermination.vue'
import BlockLayout from 'components/layout/BlockLayout.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import RecentTable from './components/RecentTable.vue'
import { ref } from 'vue'
import { useStore } from './store/useStore'
import { ActionNames } from './store/actions/actions'
import { GetterNames } from './store/getters/getters'

const store = useStore()
const root = ref(null)

store[ActionNames.GetRecent]()

const setFristAutofocusElement = () => {
  const element = root.value.querySelector('#collection-object-form input[type="text"]:not([disabled])')

  if (!store[GetterNames.IsAllLocked] && element) {
    element.focus()
  }
}

const unsubscribe = store.$onAction(
  ({
    name,
    after
  }) => {
    if (name !== ActionNames.CreateNewSpecimen) {
      return
    }

    after(_ => {
      setFristAutofocusElement()
    })
  })
</script>

<style lang="scss">
#vue-simple-new-specimen-container {
  flex-direction: column-reverse;
  margin: 0 auto;
  margin-top: 1em;
  max-width: 1240px;

  #collection-object-form {
    display: grid;
    grid-template-columns: repeat(2, minmax(250px, 1fr) );
    gap: 1em;
    grid-auto-flow: dense;
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
