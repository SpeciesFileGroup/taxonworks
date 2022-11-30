<template>
  <div>
    <h1>Stepwise determinations</h1>
    <NavBar>
      <div class="flex-separate">
        <span>{{ selectedLabel }}</span>
        <VBtn
          color="create"
          :disabled="!collectionObjects.length || !taxonDetermination"
          @click="handleClick"
        >
          Add determination
        </VBtn>
      </div>
    </NavBar>
    <div class="horizontal-left-content align-start">
      <div class="full_width">
        <LabelList class="margin-medium-bottom" />
        <CollectionObjectList />
      </div>

      <div class="margin-medium-left">
        <CuttoffInput class="margin-medium-bottom" />
        <TaxonDetermination />
      </div>
    </div>
    <VSpinner
      v-if="isLoading"
      full-screen
    />
    <VSpinner
      v-if="isCreating"
      full-screen
      legend="Creating determinations..."
    />
    <ConfirmationModal ref="confirmationModalRef" />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import TaxonDetermination from './components/TaxonDetermination.vue'
import CollectionObjectList from './components/CollectionObject/CollectionObjectList.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import NavBar from 'components/layout/NavBar.vue'
import LabelList from './components/LabelList.vue'
import VSpinner from 'components/spinner.vue'
import useStore from './composables/useStore.js'
import CuttoffInput from './components/CutoffInput.vue'
import ConfirmationModal from 'components/ConfirmationModal.vue'

const {
  isCreating,
  isLoading,
  selectedLabel,
  createDeterminations,
  collectionObjects,
  taxonDetermination,
  selectedCOIds
} = useStore()

const confirmationModalRef = ref(null)

const handleClick = async () => {
  const ok =
    selectedCOIds.value.length < 5 ||
    await confirmationModalRef.value.show({
      title: 'Create taxon determinations',
      message: 'This will add the current taxon determination to all collection object selected. Are you sure you want to proceed?',
      confirmationWord: 'CREATE',
      okButton: 'Create',
      cancelButton: 'Cancel',
      typeButton: 'submit'
    })

  if (ok) {
    createDeterminations()
  }
}

</script>

<script>
export default {
  name: 'StepwiseDeterminations'
}
</script>
