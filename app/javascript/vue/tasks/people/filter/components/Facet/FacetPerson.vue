<template>
  <div>
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
          value="cached"
        >
        Exact
      </label>
    </div>
    <div class="field">
      <label>Near (Levenshtein)</label>
      <InputRange
        v-model="params.levenshtein_cuttoff"
        :min="1"
        :max="5"
      />
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
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse'
import InputRange from 'components/ui/Input/InputRange.vue'

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
  get () {
    return props.modelValue
  },

  set (value) {
    emit('update:modelValue', value)
  }
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
