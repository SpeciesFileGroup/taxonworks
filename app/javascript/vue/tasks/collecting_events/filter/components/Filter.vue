<template>
  <FacetGeographic v-model="params" />
  <FaceDeterminations v-model="params" />
  <FacetIdentifiers v-model="params" />
  <FacetCollectors
    v-model="params"
    role="Collector"
    title="Collectors"
    klass="CollectingEvent"
    param-people="collector_id"
    param-any="collector_ids_or"
  />
  <FacetMaterial v-model="params" />
  <FacetMatchIdentifiers v-model="params" />
  <FacetKeywords
    target="CollectingEvent"
    v-model="params"
  />
  <FacetUsers v-model="params" />
  <FacetCollectingEventAttributes v-model="params" />
  <FacetDataAttribute v-model="params" />
  <FacetWith
    v-for="param in WIDTH_PARAMS"
    :key="param"
    :title="param"
    :param="param"
    v-model="params"
  />
</template>

<script setup>
import FacetIdentifiers from 'components/Filter/Facets/shared/FacetIdentifiers.vue'
import FacetGeographic from 'components/Filter/Facets/shared/FacetGeographic.vue'
import FacetUsers from 'components/Filter/Facets/shared/FacetUsers.vue'
import FacetCollectingEventAttributes from 'components/Filter/Facets/CollectingEvent/FacetCollectingEvent/FacetCollectingEvent.vue'
import FacetKeywords from 'components/Filter/Facets/shared/FacetTags.vue'
import FaceDeterminations from 'components/Filter/Facets/CollectionObject/Determiner/FacetDetermination.vue'
import FacetMaterial from 'components/Filter/Facets/CollectionObject/FacetTypeMaterial.vue'
import FacetCollectors from 'components/Filter/Facets/shared/FacetPeople.vue'
import FacetDataAttribute from 'components/Filter/Facets/shared/FacetDataAttribute.vue'
import FacetMatchIdentifiers from 'components/Filter/Facets/shared/FacetMatchIdentifiers.vue'
import FacetWith from 'components/Filter/Facets/shared/FacetWith.vue'
import { computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const WIDTH_PARAMS = [
  'collection_objects',
  'depictions',
  'data_attributes',
  'geographic_area',
  'georeferences',
  'identifiers',
  'local_identifiers'
]

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

</script>
