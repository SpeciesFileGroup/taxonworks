<template>
  <FacetContainer>
    <h3>Preparation</h3>
    <div class="flex-separate align-start">
      <template
        v-for="(itemsGroup, index) in preparationTypes.chunk(Math.ceil(preparationTypes.length/2))"
        :key="index"
      >
        <ul class="no_bullets">
          <li
            v-for="type in itemsGroup"
            :key="type.id"
          >
            <label>
              <input
                type="checkbox"
                :value="type.id"
                v-model="selectedTypes"
                name="collection-object-type"
              >
              {{ type.name }}
            </label>
          </li>
        </ul>
      </template>
    </div>
  </FacetContainer>
</template>

<script setup>
import { computed, ref, onBeforeMount } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { sortArray } from 'helpers/arrays'
import { PreparationType } from 'routes/endpoints'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'

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

const selectedTypes = computed({
  get: () => props.modelValue.preparation_type_id || [],
  set: value => { params.value.preparation_type_id = value }
})

const preparationTypes = ref([])

onBeforeMount(async () => {
  preparationTypes.value = sortArray((await PreparationType.all()).body, 'name')
  selectedTypes.value = URLParamsToJSON(location.href).preparation_type_id || []
})
</script>
