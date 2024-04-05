<template>
  <FacetByAttribute
    controller="loans"
    v-model="params"
  />
  <FacetPerson v-model="params" />
  <FacetTags
    v-model="params"
    target="Source"
  />
  <FacetIdentifiers v-model="params" />
  <FacetMatchIdentifiers v-model="params" />
  <FacetTaxonName
    include
    v-model="params"
  />
  <FacetOtu
    v-model="params"
    target="Loan"
  />
  <FacetLoanItemStatus v-model="params" />
  <FacetDateRange
    title="Date requested"
    param="date_requested"
    v-model="params"
  />
  <FacetDateRange
    title="Date sent"
    param="date_sent"
    v-model="params"
  />
  <FacetDateRange
    title="Date received"
    param="date_received"
    v-model="params"
  />
  <FacetDateRange
    title="Date return expected"
    param="date_return_expected"
    v-model="params"
  />
  <FacetDateRange
    title="Date closed"
    param="date_closed"
    v-model="params"
  />
  <FacetUsers v-model="params" />
  <FacetNotes v-model="params" />
  <FacetWith
    title="overdue"
    param="overdue"
    :options="OVERDUE_OPTIONS"
    v-model="params"
  />
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
import { computed } from 'vue'
import FacetTags from '@/components/Filter/Facets/shared/FacetTags.vue'
import FacetWith from '@/components/Filter/Facets/shared/FacetWith.vue'
import FacetUsers from '@/components/Filter/Facets/shared/FacetHousekeeping/FacetHousekeeping.vue'
import FacetNotes from '@/components/Filter/Facets/shared/FacetNotes.vue'
import FacetByAttribute from '@/components/Filter/Facets/shared/FacetByAttribute.vue'
import FacetIdentifiers from '@/components/Filter/Facets/shared/FacetIdentifiers.vue'
import FacetMatchIdentifiers from '@/components/Filter/Facets/shared/FacetMatchIdentifiers.vue'
import FacetTaxonName from '@/components/Filter/Facets/TaxonName/FacetTaxonName.vue'
import FacetDateRange from '@/components/Filter/Facets/shared/FacetDateRange.vue'
import FacetLoanItemStatus from './Facet/FacetLoanItemStatus.vue'
import FacetOtu from '@/components/Filter/Facets/Otu/FacetOtu.vue'
import FacetPerson from './Facet/FacetPerson.vue'
import FacetDiffModel from '@/components/Filter/Facets/shared/FacetDiffMode.vue'

const WITH_PARAMS = ['documentation', 'identifiers']

const OVERDUE_OPTIONS = [
  {
    label: 'Both',
    value: undefined
  },
  {
    label: 'Is overdue',
    value: true
  },
  {
    label: 'Is not overdue',
    value: false
  }
]

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})
</script>
