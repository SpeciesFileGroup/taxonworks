<template>
  <FacetContainer>
    <h3>Identifiers</h3>
    <div class="field">
      <label>Identifier</label>
      <br>
      <input
        type="text"
        v-model="params.identifier"
      >
    </div>
    <div class="field">
      <ul class="no_bullets">
        <li
          v-for="item in MATCH_OPTIONS"
          :key="item.value"
        >
          <label>
            <input
              type="radio"
              :value="item.value"
              :disabled="!params.identifier"
              v-model="params.identifier_exact"
              name="match-radio"
            >
            {{ item.label }}
          </label>
        </li>
      </ul>
    </div>
    <h4>In range</h4>
    <div class="horizontal-left-content">
      <div class="field separate-right">
        <label>Start:</label>
        <br>
        <input
          type="text"
          v-model="params.identifier_start"
        >
      </div>
      <div class="field">
        <label>End:</label>
        <br>
        <input
          type="text"
          v-model="params.identifier_end"
        >
      </div>
    </div>
    <h3>Namespace</h3>
    <smart-selector
      class="margin-medium-top"
      model="namespaces"
      klass="Source"
      pin-section="Namespaces"
      pin-type="Namespace"
      @selected="setNamespace"
    />
    <div
      v-if="namespace"
      class="middle flex-separate separate-top"
    >
      <span v-html="namespace.name" />
      <span
        class="button button-circle btn-undo button-default"
        @click="unsetNamespace"
      />
    </div>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import SmartSelector from 'components/ui/SmartSelector'
import { watch, computed, ref, onBeforeMount } from 'vue'
import { Namespace } from 'routes/endpoints'
import { URLParamsToJSON } from 'helpers/url/parse.js'

const MATCH_OPTIONS = [
  {
    label: 'Exact',
    value: true
  },
  {
    label: 'Partial',
    value: undefined
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
  set: value => emit('update:modelValue', value)
})

watch(
  () => params.value.identifier,
  newVal => {
    if (!newVal) {
      params.value.identifier_exact = undefined
    }
  },
  { deep: true }
)

const namespace = ref()

const setNamespace = item => {
  namespace.value = item
  params.value.namespace_id = item.id
}

const unsetNamespace = () => {
  namespace.value = undefined
  params.value.namespace_id = undefined
}

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)

  params.value.identifier = urlParams.identifier
  params.value.identifier_exact = urlParams.identifier_exact
  params.value.identifier_start = urlParams.identifier_start
  params.value.identifier_end = urlParams.identifier_end

  if (urlParams.namespace_id) {
    Namespace.find(urlParams.namespace_id).then(response => {
      setNamespace(response.body)
    })
  }
})

</script>

<style scoped>
  :deep(.vue-autocomplete-input) {
    width: 100%
  }
</style>
