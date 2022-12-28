<template>
  <FacetContainer>
    <h3>Name</h3>
    <div class="field">
      <label class="display-block">Full name</label>
      <input
        class="full_width"
        v-model="params.name"
        type="text"
      >
      <label>
        <input
          v-model="params.exact"
          type="checkbox"
          value="name"
        >
        Exact
      </label>
    </div>
    <div class="field label-above">
      <label>Near (Levenshtein)</label>
      <select v-model="params.levenshtein_cuttoff">
        <option :value="undefined" />
        <option
          v-for="n in 5"
          :key="n"
          :value="n"
        >
          {{ n }}
        </option>
      </select>
    </div>
    <h4>Parts</h4>
    <div
      v-for="({ label, param }) in fields"
      :key="param"
      class="field"
    >
      <label class="display-block">{{ label }}</label>
      <input
        class="full_width"
        type="text"
        v-model="params[param]"
      >
      <label>
        <input
          type="checkbox"
          :value="param"
          v-model="params.exact"
        >
        Exact
      </label>
    </div>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import { computed } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const fields = [
  {
    label: 'First name',
    param: 'first_name'
  },
  {
    label: 'Last name',
    param: 'last_name'
  },
  {
    label: 'Suffix',
    param: 'suffix'
  },
  {
    label: 'Prefix',
    param: 'prefix'
  }
]

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const urlParams = URLParamsToJSON(location.href)

Object.assign(params.value, {
  name: urlParams.name,
  first_name: urlParams.first_name,
  last_name: urlParams.last_name,
  suffix: urlParams.suffix,
  prefix: urlParams.prefix,
  exact: urlParams.exact || []
})

</script>
