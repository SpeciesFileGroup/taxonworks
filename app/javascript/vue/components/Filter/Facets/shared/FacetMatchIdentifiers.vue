<template>
  <FacetContainer>
    <h3>Matching identifiers</h3>
    <div class="field label-above">
      <textarea
        class="full_width"
        v-model="matchIdentifiers"
        rows="5"
      />
    </div>

    <div class="field label-above">
      <label>Delimiter</label>
      <span class="display-block">
        <i>Use \n for newlines, \t for tabs.</i>
      </span>
      <input
        v-model="delimiterIdentifier"
        type="text"
        class="full_width"
      >
    </div>

    <div class="field horizontal-left-content middle">
      <label>Type: </label>
      <VToggle
        v-model="toggleType"
        :options="['Identifier', 'Internal']"
      />
    </div>
  </FacetContainer>
</template>

<script setup>
import { computed, ref, onBeforeMount } from 'vue'
import VToggle from 'tasks/observation_matrices/new/components/newMatrix/switch.vue'
import { URLParamsToJSON } from 'helpers/url/parse'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'

const TYPE_PARAMETERS = {
  Internal: 'internal',
  Identifier: 'identifier'
}

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const type = ref(TYPE_PARAMETERS.Internal)
const delimiter = ref(',')
const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const matchIdentifiers = computed({
  get: () => props.modelValue.match_identifiers,
  set: value => {
    if (value) {
      params.value.match_identifiers = value
      params.value.match_identifiers_type = type.value
      params.value.match_identifiers_delimiter = delimiter.value
    } else {
      params.value.match_identifiers = undefined
      params.value.match_identifiers_type = undefined
      params.value.match_identifiers_delimiter = undefined
    }
  }
})

const delimiterIdentifier = computed({
  get: () => props.modelValue.match_identifiers_delimiter,
  set: value => {
    delimiter.value = value

    if (!matchIdentifiers.value) {
      params.value.match_identifiers_delimiter = undefined
    }
  }
})

const toggleType = computed({
  get: () => type.value === TYPE_PARAMETERS.Identifier,
  set: value => {
    type.value = value
      ? TYPE_PARAMETERS.Identifier
      : TYPE_PARAMETERS.Internal

    if (matchIdentifiers.value) {
      params.value.match_identifiers_type = type.value
    }
  }
})

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)

  params.value.match_identifiers = urlParams.match_identifiers
  params.value.match_identifiers_delimiter = urlParams.match_identifiers_delimiter
  params.value.match_identifiers_type = urlParams.match_identifiers_type
})

</script>
