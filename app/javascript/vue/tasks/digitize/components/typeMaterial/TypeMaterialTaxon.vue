<template>
  <fieldset>
    <legend>Taxon name</legend>
    <smart-selector
      ref="smartSelector"
      model="taxon_names"
      placeholder="Search taxon name..."
      klass="TypeMaterial"
      target="TypeMaterial"
      :params="{ 'nomenclature_group[]': 'SpeciesGroup' }"
      :autocomplete-params="{ 'nomenclature_group[]': 'SpeciesGroup' }"
      :filter="(item) => item.nomenclatural_code"
      pin-section="TaxonNames"
      pin-type="TaxonName"
      @selected="
        store.dispatch(ActionNames.SetTypeMaterialTaxonName, $event.id)
      "
    />
    <SmartSelectorItem
      :item="typeMaterial.taxon"
      @unset="store.dispatch(ActionNames.SetTypeMaterialTaxonName, null)"
    >
      <template #label="{ item }">
        <a
          :href="`/tasks/nomenclature/new_taxon_name?taxon_name_id=${item.id}`"
          v-html="item.object_tag"
        />
      </template>
    </SmartSelectorItem>
  </fieldset>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters'
import { ActionNames } from '../../store/actions/actions'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'

const store = useStore()
const typeMaterial = computed(() => store.getters[GetterNames.GetTypeMaterial])
</script>
