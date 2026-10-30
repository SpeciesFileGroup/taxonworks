<template>
  <FacetContainer>
    <h3 data-help="Containers holding at least one item of the selected types. Only items placed directly in the container are considered.">
      Contents
    </h3>
    <ul class="no_bullets">
      <li
        v-for="(label, type) in OBJECT_TYPES"
        :key="type"
      >
        <label>
          <input
            type="checkbox"
            :checked="selectedTypes.includes(type)"
            @change="(e) => toggleType(type, e.target.checked)"
          />
          {{ label }}
        </label>
      </li>
    </ul>
    <h4>Containers</h4>
    <ul class="no_bullets">
      <li
        v-for="item in containerTypes"
        :key="item.type"
      >
        <label class="capitalize">
          <input
            type="checkbox"
            :checked="selectedTypes.includes(item.type)"
            @change="(e) => toggleType(item.type, e.target.checked)"
          />
          {{ item.name }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import { computed, ref } from 'vue'
import {
  ANATOMICAL_PART,
  COLLECTION_OBJECT,
  CONTAINER,
  EXTRACT
} from '@/constants/index.js'
import { Container } from '@/routes/endpoints'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const OBJECT_TYPES = {
  [COLLECTION_OBJECT]: 'Collection object',
  [EXTRACT]: 'Extract',
  [ANATOMICAL_PART]: 'Anatomical part',
  [CONTAINER]: 'Any container'
}

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const containerTypes = ref([])

const selectedTypes = computed(() =>
  [params.value.contained_object_type || []].flat()
)

function toggleType(type, checked) {
  params.value.contained_object_type = checked
    ? [...selectedTypes.value, type]
    : selectedTypes.value.filter((t) => t !== type)
}

Container.types().then(({ body }) => {
  containerTypes.value = body
})
</script>
