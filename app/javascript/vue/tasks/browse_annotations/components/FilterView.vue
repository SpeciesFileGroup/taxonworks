<template>
  <FacetAnnotationType
    :model-value="annotationType"
    @update:model-value="$emit('annotation-type-change', $event)"
    @types-loaded="annotationTypesData = $event"
  />

  <FacetObjectType
    v-model="params"
    :used-on="currentUsedOn"
    :param-name="objectTypeParamName"
  />

  <FacetAnnotationFor
    v-model="params"
    :annotation-type="annotationType"
    :object-type="firstSelectedObjectType"
    :target="firstSelectedObjectType"
  />

  <template v-if="annotationType === 'citations'">
    <FacetSource
      v-model="params"
      klass="Citation"
    />
    <FacetWith
      v-model="params"
      title="Original"
      param="is_original"
      :options="IS_ORIGINAL_OPTIONS"
    />
    <FacetTopic
      v-model="params"
      target="Citation"
    />
    <FacetWith
      v-model="params"
      title="Citation topics"
      param="citation_topics"
    />
    <FacetText
      v-model="params"
      title="Citation topic pages"
      param-text="citation_topic_pages"
      param-exact="citation_topic_pages_exact"
    />
    <FacetWith
      v-model="params"
      title="Source documents"
      param="source_documents"
    />
    <FacetTags
      v-model="params"
      target="Citation"
    />
    <FacetNotes v-model="params" />
  </template>

  <FacetText
    v-if="annotationType === 'notes'"
    v-model="params"
    title="Text"
    param-text="text"
  />

  <template v-if="annotationType === 'identifiers'">
    <FacetText
      v-model="params"
      title="Identifier"
      param-text="query_string"
    />
    <FacetSingleRecord
      v-model="params"
      title="Namespace"
      param="namespace_id"
      model="namespaces"
      klass="Identifier"
      pin-section="Namespaces"
      pin-type="Namespace"
      :service="Namespace"
    />
    <FacetIdentifierType v-model="params" />
  </template>

  <template v-if="annotationType === 'data_attributes'">
    <FacetWith
      v-model="params"
      title="Attribute type"
      param="type"
      :options="DATA_ATTRIBUTE_TYPE_OPTIONS"
    />
    <FacetText
      v-model="params"
      title="Value (exact)"
      param-text="value"
    />
    <FacetText
      v-model="params"
      title="Import predicate (exact)"
      param-text="import_predicate"
    />
  </template>

  <template v-if="annotationType === 'alternate_values'">
    <FacetWith
      v-model="params"
      title="Alternate value type"
      param="type"
      :options="ALTERNATE_VALUE_TYPE_OPTIONS"
    />
    <FacetText
      v-model="params"
      title="Value (exact)"
      param-text="value"
    />
    <FacetSingleRecord
      v-model="params"
      title="Language"
      param="language_id"
      model="languages"
      klass="AlternateValue"
      label="english_name"
      :service="Language"
    />
  </template>

  <FacetHousekeeping v-model="params" />
</template>

<script setup>
import { computed, ref } from 'vue'
import FacetAnnotationType from './FacetAnnotationType.vue'
import FacetAnnotationFor from './FacetAnnotationFor.vue'
import FacetObjectType from './FacetObjectType.vue'
import FacetSingleRecord from './FacetSingleRecord.vue'
import FacetIdentifierType from './FacetIdentifierType.vue'
import FacetSource from '@/components/Filter/Facets/shared/FacetSource.vue'
import FacetHousekeeping from '@/components/Filter/Facets/shared/FacetHousekeeping/FacetHousekeeping.vue'
import FacetWith from '@/components/Filter/Facets/shared/FacetWith.vue'
import FacetText from '@/components/Filter/Facets/shared/FacetText.vue'
import FacetTopic from '@/components/Filter/Facets/shared/FacetTopic.vue'
import FacetTags from '@/components/Filter/Facets/shared/FacetTags.vue'
import FacetNotes from '@/components/Filter/Facets/shared/FacetNotes.vue'
import { Language, Namespace } from '@/routes/endpoints'
import {
  ALTERNATE_VALUE_ABBREVIATION,
  ALTERNATE_VALUE_ALTERNATE_SPELLING,
  ALTERNATE_VALUE_MISSPELLING,
  ALTERNATE_VALUE_TRANSLATION,
  DATA_ATTRIBUTE_INTERNAL_ATTRIBUTE,
  IMPORT_ATTRIBUTE
} from '@/constants'

const IS_ORIGINAL_OPTIONS = [
  { label: 'Both', value: undefined },
  { label: 'Original only', value: true },
  { label: 'Not original', value: false }
]

const DATA_ATTRIBUTE_TYPE_OPTIONS = [
  { label: 'Any', value: undefined },
  { label: 'Internal', value: DATA_ATTRIBUTE_INTERNAL_ATTRIBUTE },
  { label: 'Import', value: IMPORT_ATTRIBUTE }
]

const ALTERNATE_VALUE_TYPE_OPTIONS = [
  { label: 'Any', value: undefined },
  { label: 'Abbreviation', value: ALTERNATE_VALUE_ABBREVIATION },
  { label: 'Alternate spelling', value: ALTERNATE_VALUE_ALTERNATE_SPELLING },
  { label: 'Misspelling', value: ALTERNATE_VALUE_MISSPELLING },
  { label: 'Translation', value: ALTERNATE_VALUE_TRANSLATION }
]

const OBJECT_TYPE_PARAM = {
  tags: 'tag_object_type',
  notes: 'note_object_type',
  confidences: 'confidence_object_type',
  data_attributes: 'attribute_subject_type',
  citations: 'citation_object_type',
  identifiers: 'identifier_object_type',
  alternate_values: 'alternate_value_object_type',
  attributions: 'attribution_object_type',
  depictions: 'depiction_object_type',
  documentation: 'documentation_object_type'
}

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  },

  annotationType: {
    type: String,
    default: null
  }
})

const emit = defineEmits(['update:modelValue', 'annotation-type-change'])

const annotationTypesData = ref({})

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const currentUsedOn = computed(() => {
  if (!props.annotationType || !annotationTypesData.value[props.annotationType]) {
    return {}
  }
  return annotationTypesData.value[props.annotationType].used_on || {}
})

const objectTypeParamName = computed(() =>
  props.annotationType ? OBJECT_TYPE_PARAM[props.annotationType] || '' : ''
)

const firstSelectedObjectType = computed(() => {
  const val = params.value[objectTypeParamName.value]
  return Array.isArray(val) && val.length ? val[0] : undefined
})
</script>
