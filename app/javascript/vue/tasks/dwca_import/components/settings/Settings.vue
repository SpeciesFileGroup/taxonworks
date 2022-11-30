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
        <h3>Settings</h3>
      </template>
      <template #body>
        <div>
          <nomenclature-code class="margin-medium-bottom" />

          <div class="field">
            <containerize-checkbox />
            <restrict-to-nomenclature-checkbox />
            <require-type-material-success-checkbox />
          </div>

          <CatalogNumberMain />
        </div>
      </template>
    </modal-component>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import ModalComponent from 'components/ui/Modal'
import ContainerizeCheckbox from './Containerize'
import RestrictToNomenclatureCheckbox from './RestrictToNomenclature'
import RequireTypeMaterialSuccessCheckbox from './RequireTypeMaterialSuccess'
import NomenclatureCode from './NomenclatureCode.vue'
import CatalogNumberMain from './CatalogNumber/CatalogNumberMain.vue'

const showModal = ref(false)

const setModalView = value => {
  showModal.value = value
}
</script>
