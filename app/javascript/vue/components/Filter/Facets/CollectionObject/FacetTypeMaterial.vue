<template>
  <FacetContainer>
    <h3>Types</h3>
    <h4>Nomenclature code</h4>
    <div class="field">
      <ul class="no_bullets">
        <li
          v-for="(group, key) in types"
          :key="key"
        >
          <label class="uppercase">
            <input
              type="radio"
              :value="key"
              name="nomenclature-code-type"
              v-model="nomenclatureCode"
            >
            {{ key }}
          </label>
        </li>
      </ul>
    </div>
    <div
      v-if="nomenclatureCode"
      class="field"
    >
      <h4>Types</h4>
      <ul class="no_bullets">
        <li
          v-for="(item, type) in types[nomenclatureCode]"
          :key="type"
        >
          <label class="capitalize">
            <input
              v-model="params.is_type"
              :value="type"
              name="type-type"
              type="checkbox"
            >
            {{ type }}
          </label>
        </li>
      </ul>
    </div>
  </FacetContainer>
</template>

<script setup>
import { computed, ref, watch, onBeforeMount } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { TypeMaterial } from 'routes/endpoints'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const emit = defineEmits(['update:modelValue'])

const nomenclatureCode = ref()
const types = ref({})

watch(
  nomenclatureCode,
  () => {
    params.value.is_type = []
  }
)

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)

  params.value.is_type = urlParams.is_type || []

  TypeMaterial.types().then(response => {
    types.value = response.body
  })
})
</script>
