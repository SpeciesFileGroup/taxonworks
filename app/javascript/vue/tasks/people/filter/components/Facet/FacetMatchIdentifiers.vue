<template>
  <div>
    <h3>Matching identifiers</h3>
    <div class="field label-above">
      <textarea
        class="full_width"
        v-model="params.match_identifiers"
        rows="5"
      >
      </textarea>
    </div>

    <div class="field label-above">
      <label>Delimiter</label>
      <span class="display-block">
        <i>Use \n for newlines, \t for tabs.</i>
      </span>
      <input
        v-model="params.match_identifiers_delimiter"
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
  </div>
</template>

<script setup>
import { computed } from 'vue'
import VToggle from 'tasks/observation_matrices/new/components/newMatrix/switch.vue'
import { URLParamsToJSON } from 'helpers/url/parse'

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

const toggleType = computed({
  get: () => props.modelValue.match_identifiers_type === 'Identifier',
  set: value => {
    params.value.match_identifiers_type = value
      ? 'Identifier'
      : 'Internal'
  }
})

const urlParams = URLParamsToJSON(location.href)

Object.assign(params.value, {
  match_identifiers: urlParams.match_identifiers,
  match_identifiers_delimiter: urlParams.match_identifiers_delimiter,
  match_identifiers_type: urlParams.match_identifiers_type
})

</script>
