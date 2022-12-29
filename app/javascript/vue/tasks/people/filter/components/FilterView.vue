<template>
  <FacetPerson v-model="params" />
  <FacetRegex v-model="params" />
  <FacetBetweenYear
    v-model="params"
    title="Active year"
    before-param="active_before_year"
    after-param="active_after_year"
  />
  <FacetBetweenYear
    v-model="params"
    title="Born year"
    before-param="born_before_year"
    after-param="born_after_year"
  />
  <FacetBetweenYear
    v-model="params"
    title="Died year"
    before-param="died_before_year"
    after-param="died_after_year"
  />
  <FacetTimesRepeated v-model="params" />
  <FacetRolesTotalUsed v-model="params" />
  <FacetRoles
    v-model="params"
    title="Roles"
    param="role"
  />
  <FacetRoles
    v-model="params"
    title="Without roles"
    param="except_role"
  />
  <FacetProjects v-model="params" />
  <FacetMatchIdentifiers v-model="params" />
  <FacetNotes v-model="params" />
  <FacetTags
    v-model="params"
    target="CollectionObject"
  />
  <FacetDataAttributes v-model="params" />
  <FacetIdentifiers v-model="params" />
  <FacetUsers v-model="params" />
  <FacetWith
    v-for="param in withFilter"
    :key="param"
    v-model="params"
    :param="param"
  />
  <WithComponent
    v-for="param in WITH_PARAMS"
    :key="param"
    :title="param"
    :param="param"
    v-model="params"
  />
</template>

<script setup>

import FacetUsers from 'components/Filter/Facets/shared/FacetUsers.vue'
import FacetIdentifiers from 'components/Filter/Facets/shared/FacetIdentifiers.vue'
import FacetTags from 'components/Filter/Facets/shared/FacetTags.vue'
import FacetRoles from './Facet/FacetRoles.vue'
import FacetRolesTotalUsed from './Facet/FacetRolesTotalUsed.vue'
import FacetPerson from './Facet/FacetPerson.vue'
import FacetBetweenYear from './Facet/FacetBetweenYear.vue'
import FacetTimesRepeated from './Facet/FacetTimesRepeated.vue'
import FacetProjects from './Facet/FacetProjects.vue'
import FacetRegex from './Facet/FacetRegex.vue'
import FacetNotes from 'components/Filter/Facets/shared/FacetNotes.vue'
import FacetDataAttributes from 'components/Filter/Facets/shared/FacetDataAttribute.vue'
import FacetWith from './Facet/FacetWith.vue'
import FacetMatchIdentifiers from 'components/Filter/Facets/shared/FacetMatchIdentifiers.vue'
import WithComponent from 'components/Filter/Facets/shared/FacetWith.vue'
import { computed } from 'vue'

const withFilter = ['first_name', 'suffix', 'prefix']
const WITH_PARAMS = [
  'identifiers',
  'data_attributes',
  'notes'
]

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

</script>
