<template>
  <FacetSoundName v-model="params" />
  <FacetOtu
    v-model="params"
    :target="SOUND"
  />
  <FacetConveyanceObjectType v-model="params" />
  <FacetCollectionObject v-model="params" />
  <FacetFieldOccurrence v-model="params" />
  <FacetTags
    :target="SOUND"
    v-model="params"
  />
  <FacetUsers v-model="params" />
  <FacetWith
    v-for="param in WITH_PARAMS"
    :key="param"
    :title="param"
    :param="param"
    v-model="params"
  />
</template>

<script setup>
import { computed } from 'vue'
import { SOUND } from '@/constants'
import FacetFieldOccurrence from '@/components/Filter/Facets/FieldOccurrence/FacetFieldOccurrence.vue'
import FacetCollectionObject from '@/components/Filter/Facets/CollectionObject/FacetCollectionObject.vue'
import FacetUsers from '@/components/Filter/Facets/shared/FacetHousekeeping/FacetHousekeeping.vue'
import FacetTags from '@/components/Filter/Facets/shared/FacetTags.vue'
import FacetOtu from '@/components/Filter/Facets/Otu/FacetOtu.vue'
import FacetWith from '@/components/Filter/Facets/shared/FacetWith.vue'
import FacetSoundName from '@/components/Filter/Facets/Sound/FacetSoundName.vue'
import FacetConveyanceObjectType from '@/components/Filter/Facets/Conveyance/FacetConveyanceObjectType.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const WITH_PARAMS = ['citations', 'conveyances', 'with_name']

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})
</script>
