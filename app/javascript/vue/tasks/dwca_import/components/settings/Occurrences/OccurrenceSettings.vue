<template>
  <h3>DwC Occurrence Import Settings</h3>
  <div class="field">
    <CheckboxSetting
      v-for="(label, property) in OCCURRENCE_CHECKBOX_SETTINGS"
      :key="property"
      :label="label"
      :property="property"
    />
  </div>

  <h4>Geographic Areas</h4>
  <div class="field">
    <GeographicAreaDataOrigin class="margin-medium-bottom" />
    <CheckboxSetting
      v-for="(label, property) in GEOGRAPHIC_AREA_SETTINGS"
      :key="property"
      :label="label"
      :property="property"
    />
  </div>

  <CatalogNumberMain />
</template>

<script setup>
import CatalogNumberMain from './CatalogNumber/CatalogNumberMain.vue'
import GeographicAreaDataOrigin from './GeographicAreaDataOrigin.vue'
import CheckboxSetting from '../CheckboxSetting.vue'

const OCCURRENCE_CHECKBOX_SETTINGS = {
  containerize_dup_cat_no:
    'Containerize specimen with existing ones when catalog number already exists',
  restrict_to_existing_nomenclature:
    ' Restrict import to existing nomenclature only',
  require_type_material_success:
    'Error records with unprocessable typeStatus information',
  require_tripcode_match_verbatim:
    'Error records when computed Trip code will not match fieldNumber',
  require_catalog_number_match_verbatim:
    'Error records when computed identifier will not match catalogNumber',
  enable_organization_determiners:
    'Enable searching for Organization name in determinedBy field',
  enable_organization_determiners_alt_name:
    'Also search for Organization alternate name'
}

const GEOGRAPHIC_AREA_SETTINGS = {
  require_geographic_area_exact_match:
    'Only search for the finest geographical name provided',
  require_geographic_area_has_shape:
    'Require that the matched geographic area has a shape',
  require_geographic_area_exist:
    'Error if no geographic area with provided name exists (works best with "Only search for the finest geographical name provided")'
}
</script>
