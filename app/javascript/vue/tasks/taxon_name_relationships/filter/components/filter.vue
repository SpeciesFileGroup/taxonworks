<template>
  <FacetTaxonNameRelationshipType
    v-model="params"
  />

  <FacetTaxonName
    include
    v-model="params"
  >
    <template #top>
      <div class="subj-obj">
        <SubjectObjectSelector
          v-model="params.taxon_name_subject_object"
        />
      </div>
    </template>
  </FacetTaxonName>

  <FacetUsers v-model="params" />
  <FacetWith
    v-for="param in WITH_PARAMS"
    :key="param"
    :title="param"
    :param="param"
    v-model="params"
  />
  <FacetDiffModel v-model="params" />
</template>

<script setup>
import FacetDiffModel from '@/components/Filter/Facets/shared/FacetDiffMode.vue'
import FacetUsers from '@/components/Filter/Facets/shared/FacetHousekeeping/FacetHousekeeping.vue'
import FacetWith from '@/components/Filter/Facets/shared/FacetWith.vue'
import FacetTaxonName from '@/components/Filter/Facets/TaxonName/FacetTaxonName.vue'
import FacetTaxonNameRelationshipType from './filters/FacetTaxonNameRelationshipType.vue'
import SubjectObjectSelector from './SubjectObjectSelector.vue'

const WITH_PARAMS = ['citations', 'notes', 'origin_citation', 'verifiers']

const params = defineModel({
  type: Object,
  default: () => ({})
})

</script>

<style scoped>
.subj-obj {
  margin-bottom: 1.5em;
}
</style>