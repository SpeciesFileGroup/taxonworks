<template>
  <switch-component
    class="margin-medium-bottom"
    :options="sections"
    use-index
    v-model="tabIndex"
  />
  <component
    :is="componentName"
    v-model="combination"
  />
</template>

<script setup>

import { computed, ref } from 'vue'
import { useStore } from 'vuex'
import { NOMENCLATURE_CODE_BOTANY } from 'constants/index.js'
import SwitchComponent from 'components/switch.vue'
import AuthorPerson from './AuthorPeople.vue'
import AuthorSource from './AuthorSource.vue'
import AuthorVerbatim from './AuthorVerbatim.vue'

const store = useStore()

const TAB = {
  Source: AuthorSource,
  Verbatim: AuthorVerbatim,
  Person: AuthorPerson
}

function getTabLabel (label, hasData) {
  return label + (hasData ? ' ✓' : '')
}

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  },

  taxon: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const tabIndex = ref(0)
const combination = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const componentName = computed(() => Object.values(TAB)[tabIndex.value])

const verbatimFilled = computed(() => combination.value.verbatim_author || combination.value.verbatim_year)
const hasRoles = computed(() => combination.value.roles_attributes.length)
const sections = computed(() =>
  props.taxon.nomenclatural_code === NOMENCLATURE_CODE_BOTANY
    ? [
        getTabLabel('Source', combination.value.origin_citation_attributes.source_id),
        getTabLabel('Verbatim', verbatimFilled.value),
        getTabLabel('Person', hasRoles.value)
      ]
    : [getTabLabel('Source', combination.value.origin_citation_attributes.source_id)]
)
</script>
