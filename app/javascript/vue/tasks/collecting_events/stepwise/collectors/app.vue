<template>
  <div>
    <h1>Stepwise collectors</h1>
    <NavBar>
      <div class="flex-separate">
        <span>{{ selectedCollectorString }}</span>
        <VBtn
          color="create"
          :disabled="!selectedCEIds.length || !collectorRoleList.length"
          @click="handleClick"
        >
          Set collectors
        </VBtn>
      </div>
    </NavBar>
    <div class="horizontal-left-content align-start">
      <div class="full_width">
        <LabelList class="margin-medium-bottom" />
        <CollectingEventList v-if="selectedCollectorString" />
      </div>

      <div
        id="right-column"
        class="margin-medium-left"
      >
        <CuttoffInput class="margin-medium-bottom" />
        <Collectors />
      </div>
    </div>
    <VSpinner
      v-if="isLoading"
      full-screen
    />
    <VSpinner
      v-if="isCreating"
      full-screen
      legend="Setting collectors..."
    />
    <ConfirmationModal ref="confirmationModalRef" />
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import Collectors from './components/Collector.vue'
import CollectingEventList from './components/CollectingEvent/CollectingEventList.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import NavBar from '@/components/layout/NavBar.vue'
import LabelList from './components/LabelList.vue'
import VSpinner from '@/components/spinner.vue'
import useStore from './composables/useStore.js'
import CuttoffInput from './components/CutoffInput.vue'
import ConfirmationModal from '@/components/ConfirmationModal.vue'

const {
  isCreating,
  isLoading,
  selectedCollectorString,
  createCollectors,
  collectorRoleList,
  loadCollectingEvents,
  ghostCount,
  selectedCEIds
} = useStore()

const confirmationModalRef = ref(null)

const handleClick = async () => {
  const ok =
    selectedCEIds.value.length < 5 ||
    (await confirmationModalRef.value.show({
      title: 'Create collectors',
      message:
        'This will add the chosen collectors to all selected collecting events. Are you sure you want to proceed?',
      confirmationWord: 'CREATE',
      okButton: 'Create',
      cancelButton: 'Cancel',
      typeButton: 'submit'
    }))

  if (ok) {
    createCollectors()
  }
}

watch(selectedCollectorString, (collectorString) => {
  if (collectorString) {
    loadCollectingEvents(1).then((_) => {
      if (ghostCount.value) {
        TW.workbench.alert.create(
          `Warning, ${ghostCount.value} additional collecting events identical except for whitespace are included`,
          'notice'
        )
      }
    })
  }
})
</script>

<script>
export default {
  name: 'StepwiseCollectors'
}
</script>

<style scoped>
#right-column {
  width: 600px;
}
</style>
