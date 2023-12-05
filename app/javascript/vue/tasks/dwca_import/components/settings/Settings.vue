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
            <SettingsCheckbox :setting="settings.useExistingTaxonHierarchy" />
          </div>

          <h3>DwC Occurrence Import Settings</h3>
          <div class="field">
            <SettingsCheckbox :setting="settings.containerize" />
            <SettingsCheckbox :setting="settings.restrictToNomenclature" />
            <SettingsCheckbox :setting="settings.requireTypeMaterialSuccess" />
            <SettingsCheckbox :setting="settings.requireTripCodeMatchVerbatim" />
            <SettingsCheckbox :setting="settings.requireCatalogNumberMatchVerbatim" />
            <SettingsCheckbox :setting="settings.enableOrganizationDeterminers" />
            <SettingsCheckbox :setting="settings.enableOrganizationDeterminersAltName" />
          </div>

          <h4>Geographic Areas</h4>
          <div class="field">
            <geographic-area-data-origin class="margin-medium-bottom" />
            <SettingsCheckbox :setting="settings.requireGeographicAreaHasShape" />
            <SettingsCheckbox :setting="settings.requireGeographicAreaExactMatch" />
            <SettingsCheckbox :setting="settings.requireGeographicAreaExists" />
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
import SettingsCheckbox from './SettingsCheckbox.vue'
import NomenclatureCode from './NomenclatureCode.vue'
import GeographicAreaDataOrigin from './GeographicAreaDataOrigin.vue'
import CatalogNumberMain from './CatalogNumber/CatalogNumberMain.vue'

const showModal = ref(false)

const setModalView = (value) => {
  showModal.value = value
}

const settings = {
  useExistingTaxonHierarchy:
    { use_existing_taxon_hierarchy: 'Taxon names without parentNameUsageID will match existing nomenclature instead of being children of Root' },

  containerize:
    { containerize: 'Containerize specimen with existing ones when catalog number already exists' },
  requireTypeMaterialSuccess:
    { require_type_material_success: 'Error records with unprocessable typeStatus information' },
  restrictToNomenclature:
    { restrict_to_existing_nomenclature: 'Restrict import to existing nomenclature only' },
  requireTripCodeMatchVerbatim:
    { require_tripcode_match_verbatim: 'Error records when computed Trip code will not match fieldNumber' },
  requireCatalogNumberMatchVerbatim:
    { require_catalog_number_match_verbatim: 'Error records when computed identifier will not match catalogNumber' },
  enableOrganizationDeterminers:
    { enable_organization_determiners: 'Enable searching for Organization name in determinedBy field' },
  enableOrganizationDeterminersAltName:
    { enable_organization_determiners_alt_name: 'Also search for Organization alternate name' },
  requireGeographicAreaHasShape:
    { require_geographic_area_has_shape: 'Require that the matched geographic area has a shape' },
  requireGeographicAreaExactMatch:
    { require_geographic_area_exact_match: 'Only search for the finest geographical name provided' },
  requireGeographicAreaExists:
    { require_geographic_area_exists: 'Error if no geographic area with provided name exists (works best with "Only search for the finest geographical name provided")' }
}
</script>
