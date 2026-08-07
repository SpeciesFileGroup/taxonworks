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

  <FacetHousekeeping v-model="params" />
</template>

<script setup>
import { computed, ref } from 'vue'
import FacetAnnotationType from './FacetAnnotationType.vue'
import FacetAnnotationFor from './FacetAnnotationFor.vue'
import FacetObjectType from './FacetObjectType.vue'
import FacetHousekeeping from '@/components/Filter/Facets/shared/FacetHousekeeping/FacetHousekeeping.vue'

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
