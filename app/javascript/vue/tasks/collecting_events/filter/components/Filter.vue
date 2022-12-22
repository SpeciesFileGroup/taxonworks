<template>
  <div>
    <FacetGeographic
      class="margin-medium-bottom panel content"
      v-model="params"
    />
    <FaceDeterminations
      class="margin-medium-bottom panel content"
      v-model="params"
    />
    <FacetIdentifiers
      class="margin-medium-bottom panel content"
      v-model="params"
    />
    <FacetCollectors
      class="margin-medium-bottom panel content"
      v-model="params"
      role="Collector"
      title="Collectors"
      klass="CollectingEvent"
      param-people="collector_id"
      param-any="collector_ids_or"
    />
    <FacetMaterial
      class="margin-medium-bottom panel content"
      v-model="params"
    />
    <FacetMatchIdentifiers
      class="margin-medium-bottom panel content"
      v-model="params"
    />
    <FacetKeywords
      class="margin-medium-bottom panel content"
      target="CollectingEvent"
      v-model="params"
    />
    <FacetUsers
      class="margin-medium-bottom panel content"
      v-model="params"
    />
    <FacetCollectingEventAttributes
      class="margin-medium-bottom panel content"
      v-model="params"
    />
    <FacetDataAttribute
      v-model="params"
      class="margin-medium-bottom panel content"
    />
    <div class="panel content">
      <FacetWith
        class="margin-large-bottom"
        v-for="param in WIDTH_PARAMS"
        :key="param"
        :title="param"
        :param="param"
        v-model="params[param]"
      />
    </div>
  </div>
</template>

<script setup>
import FacetIdentifiers from 'tasks/collection_objects/filter/components/filters/identifier'
import FacetGeographic from 'tasks/collection_objects/filter/components/filters/geographic'
import FacetUsers from 'tasks/collection_objects/filter/components/filters/user'
import FacetCollectingEventAttributes from 'tasks/collection_objects/filter/components/filters/collectingEvent/collectingEvent'
import FacetKeywords from 'tasks/sources/filter/components/filters/tags'
import FaceDeterminations from 'tasks/collection_objects/filter/components/filters/otu'
import FacetMaterial from 'tasks/collection_objects/filter/components/filters/types'
import FacetCollectors from 'tasks/collection_objects/filter/components/filters/shared/people'
import FacetDataAttribute from 'tasks/collection_objects/filter/components/filters/DataAttributes/FacetDataAttribute.vue'
import FacetMatchIdentifiers from 'tasks/people/filter/components/Facet/FacetMatchIdentifiers.vue'
import FacetWith from 'tasks/sources/filter/components/filters/with'
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
<style scoped>
:deep(.btn-delete) {
    background-color: #5D9ECE;
  }
</style>
