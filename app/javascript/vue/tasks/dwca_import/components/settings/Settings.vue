<template>
  <div>
    <button
      @click="setModalView(true)"
      class="button normal-input button-default"
    >
      Settings
    </button>
    <modal-component
      v-if="showModal"
      @close="setModalView(false)"
      :container-style="{
        width: '700px',
        maxHeight: '80vh',
        overflow: 'scroll'
      }"
    >
      <template #header>
        <h2>Settings</h2>
      </template>
      <template #body>
        <div>
          <NomenclatureCode />
          <component :is="SETTING_TYPE_COMPONENT[datasetType]" />
        </div>
      </template>
    </modal-component>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters'
import ModalComponent from '@/components/ui/Modal'
import NomenclatureCode from './NomenclatureCode.vue'
import OccurrenceSettings from './Occurrences/OccurrenceSettings.vue'
import ChecklistSettings from './Checklist/ChecklistSettings'

import {
  IMPORT_DATASET_DWC_CHECKLIST,
  IMPORT_DATASET_DWC_OCCURRENCES
} from '@/constants'

const SETTING_TYPE_COMPONENT = {
  [IMPORT_DATASET_DWC_CHECKLIST]: ChecklistSettings,
  [IMPORT_DATASET_DWC_OCCURRENCES]: OccurrenceSettings
}

const showModal = ref(false)
const store = useStore()

const datasetType = computed(() => store.getters[GetterNames.GetDataset].type)

const setModalView = (value) => {
  showModal.value = value
}
</script>
