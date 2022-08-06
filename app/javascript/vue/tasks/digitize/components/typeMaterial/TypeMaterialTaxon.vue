<template>
  <fieldset>
    <legend>Taxon name</legend>
    <smart-selector
      ref="smartSelector"
      model="taxon_names"
      klass="TypeMaterial"
      target="TypeMaterial"
      :params="{ 'nomenclature_group[]': 'SpeciesGroup' }"
      :autocomplete-params="{ 'nomenclature_group[]': 'SpeciesGroup' }"
      :filter="item => item.nomenclatural_code"
      pin-section="TaxonNames"
      pin-type="TaxonName"
      @selected="store.dispatch(ActionNames.SetTypeMaterialTaxonName, $event.id)"
    />
    <template v-if="typeMaterial.taxon">
      <hr>
      <div class="flex-separate middle">
        <a
          :href="`/tasks/nomenclature/new_taxon_name?taxon_name_id=${typeMaterial.taxon.id}`"
          v-html="typeMaterial.taxon.object_tag"
        />
        <button
          type="button"
          class="button circle-button btn-undo button-default"
          @click="store.dispatch(ActionNames.SetTypeMaterialTaxonName, null)"
        />
      </div>
    </template>
  </fieldset>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters'
import { ActionNames } from '../../store/actions/actions'
import SmartSelector from 'components/ui/SmartSelector.vue'

const store = useStore()
const typeMaterial = computed(() => store.getters[GetterNames.GetTypeMaterial])

</script>
