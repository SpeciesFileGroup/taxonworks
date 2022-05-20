<template>
  <div>
    <h1>Stepwise determinations</h1>
    <NavBar>
      <div class="flex-separate">
        <span>{{ selectedLabel }}</span>
        <VBtn
          color="create"
          :disabled="!collectionObjects.length || !taxonDetermination"
          @click="createDeterminations"
        >
          Add determination
        </VBtn>
      </div>
    </NavBar>
    <div class="horizontal-left-content align-start">
      <TaxonDetermination class="margin-medium-right"/>
      <div class="full_width">
        <LabelList class="margin-medium-bottom"/>
        <CollectionObjectList />
      </div>
    </div>
    <VSpinner 
      v-if="isLoading"
      full-screen
    />
  </div>
</template>

<script>
export default {
  name: 'StepwiseDeterminations'
}
</script>

<script setup>

import TaxonDetermination from './components/TaxonDetermination.vue'
import CollectionObjectList from './components/CollectionObjectList.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import NavBar from 'components/layout/NavBar.vue'
import LabelList from './components/LabelList.vue'
import VSpinner from 'components/spinner.vue'
import useStore from './composables/useStore.js'

const {
  isLoading,
  selectedLabel,
  createDeterminations,
  collectionObjects,
  taxonDetermination

} = useStore()

</script>