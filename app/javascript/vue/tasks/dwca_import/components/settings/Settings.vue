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
          <nomenclature-code/>
          <h3>DwC Checklist Import Settings</h3>
          <div class="field">
            <use-existing-taxon-hierarchy />
          </div>

          <h3>DwC Occurrence Import Settings</h3>
          <div class="field">
            <containerize-checkbox />
            <restrict-to-nomenclature-checkbox />
            <require-type-material-success-checkbox />
            <require-trip-code-match-verbatim-checkbox />
            <require-catalog-number-match-verbatim-checkbox />
            <enable-organization-determiners />
          </div>

          <h4>Geographic Areas</h4>
          <div class="field">
            <geographic-area-data-origin class="margin-medium-bottom" />
            <require-geographic-area-has-shape-checkbox />
            <require-geographic-area-exact-match />
            <require-geographic-area-exists />
          </div>

          <CatalogNumberMain />
        </div>
      </template>
    </modal-component>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import ModalComponent from '@/components/ui/Modal'
import ContainerizeCheckbox from './Containerize'
import RestrictToNomenclatureCheckbox from './RestrictToNomenclature'
import RequireTypeMaterialSuccessCheckbox from './RequireTypeMaterialSuccess'
import RequireTripCodeMatchVerbatimCheckbox from './RequireTripCodeMatchVerbatim'
import RequireCatalogNumberMatchVerbatimCheckbox from './RequireCatalogNumberMatchVerbatim.vue'
import EnableOrganizationDeterminers from './EnableOrganizationDeterminers.vue'
import NomenclatureCode from './NomenclatureCode.vue'
import GeographicAreaDataOrigin from './GeographicAreaDataOrigin.vue'
import RequireGeographicAreaHasShapeCheckbox from './RequireGeographicAreaHasShapeCheckbox.vue'
import RequireGeographicAreaExactMatch from './RequireGeographicAreaExactMatch.vue'
import RequireGeographicAreaExists from './RequireGeographicAreaExists.vue'
import CatalogNumberMain from './CatalogNumber/CatalogNumberMain.vue'
import UseExistingTaxonHierarchy from './UseExistingTaxonHierarchy.vue'

const showModal = ref(false)

const setModalView = (value) => {
  showModal.value = value
}
</script>
