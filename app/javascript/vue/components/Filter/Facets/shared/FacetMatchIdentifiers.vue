<template>
  <FacetContainer>
    <h3>Matching identifiers</h3>
    <div class="field label-above">
      <textarea
        v-tabkey
        class="full_width"
        v-model="matchIdentifiers"
        rows="5"
      />
    </div>

    <div class="field label-above">
      <label><b>Delimiter</b></label>
      <span class="display-block">
        <i>Use </i>\n<i> for newlines, </i>\t<i> for tabs.</i>
      </span>
      <input
        v-model="delimiterIdentifier"
        type="text"
        class="full_width"
      />
    </div>

    <div class="field horizontal-left-content middle">
      <label>Type: </label>
      <VToggle
        v-model="toggleType"
        :options="['Identifier', 'Internal']"
      />
    </div>
    <div class="field">
      <label>
        <input
          type="checkbox"
          v-model="sortBy"
        />
        Sort as listed
      </label>
    </div>
  </FacetContainer>
</template>

<script setup>
import { computed, ref, onBeforeMount } from 'vue'
import { vTabkey } from '@/directives'
import VToggle from '@/tasks/observation_matrices/new/components/Matrix/switch.vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const SORT_BY_VALUE = 'match_identifiers'

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

const type = ref()
const delimiter = ref()
const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const sortBy = computed({
  get: () => params.value.order_by === SORT_BY_VALUE,
  set: (value) => {
    params.value.order_by = value ? SORT_BY_VALUE : undefined
  }
})

const matchIdentifiers = computed({
  get: () => props.modelValue.match_identifiers,
  set: (value) => {
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
  set: (value) => {
    delimiter.value = value

    if (!matchIdentifiers.value) {
      params.value.match_identifiers_delimiter = undefined
    } else {
      params.value.match_identifiers_delimiter = value
    }
  }
})

const toggleType = computed({
  get: () => type.value === TYPE_PARAMETERS.Identifier,
  set: (value) => {
    type.value = value ? TYPE_PARAMETERS.Identifier : TYPE_PARAMETERS.Internal

    if (matchIdentifiers.value) {
      params.value.match_identifiers_type = type.value
    }
  }
})

onBeforeMount(() => {
  type.value = params.value.match_identifiers_type || TYPE_PARAMETERS.Internal
  delimiter.value = params.value.match_identifiers_delimiter || ','
})
</script>
