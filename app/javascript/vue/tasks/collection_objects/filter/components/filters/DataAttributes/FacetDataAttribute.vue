<template>
  <div>
    <h3>Data attributes</h3>
    <label>Predicate</label>
    <smart-selector
      class="margin-medium-bottom"
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{'type[]' : 'Predicate'}"
      get-url="/controlled_vocabulary_terms/"
      model="predicates"
      buttons
      inline
      klass="DataAttribute"
      @selected="addToArray(predicates, $event)"
    />
    <display-list
      :list="predicates"
      @delete="removeFromArray(predicates, $event)"
      label="name"
    />
    <label>Value</label>
    <div class="field">
      <textarea
        v-model="inputValue"
        class="full_width"
        rows="5"
      ></textarea>
      <div class="flex-separate middle">
        <VBtn
          color="primary"
          medium
          :disabled="!inputValue.length"
          @click="addValue"
        >
          Add
        </VBtn>
        <label>
          <input
            v-model="params.data_attribute_exact"
            type="checkbox"
          >
          Data attribute exact
        </label>
      </div>
    </div>
    <display-list
      :list="params.data_attribute_value"
      :delete-warning="false"
      @delete-index="params.data_attribute_value.splice($event, 1)"
    />
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { ControlledVocabularyTerm } from 'routes/endpoints'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { addToArray, removeFromArray } from 'helpers/arrays.js'
import SmartSelector from 'components/ui/SmartSelector.vue'
import displayList from 'components/displayList.vue'
import VBtn from 'components/ui/VBtn/index.vue'

const props = defineProps({
  modelValue: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])
const predicates = ref([])

const params = computed({
  get () {
    return props.modelValue
  },

  set (value) {
    emit('update:modelValue', value)
  }
})

watch(
  predicates,
  newVal => {
    params.value.data_attribute_predicate_id = newVal.map(item => item.id)
  },
  { deep: true }
)

watch(
  () => props.modelValue,
  (newVal, oldVal) => {
    if (
      !newVal.data_attribute_predicate_id.length &&
      newVal.data_attribute_predicate_id.length !== oldVal.data_attribute_predicate_id.length
    ) {
      predicates.value = []
    }
  },
  { deep: true }
)

const inputValue = ref('')

const addValue = () => {
  params.value.data_attribute_value.push(inputValue.value)
  inputValue.value = ''
}

const {
  data_attribute_value: dataAttributeValue = [],
  data_attribute_predicate_id: predicateIds = [],
  data_attribute_exact: dataAttributeExact
} = URLParamsToJSON(location.href)

Object.assign(params.value, {
  data_attribute_value: dataAttributeValue,
  data_attribute_predicate_id: predicateIds,
  data_attribute_exact: dataAttributeExact
})

if (predicateIds.length) {
  ControlledVocabularyTerm.where({ id: predicateIds }).then(({ body }) => {
    predicates.value = body
  })
}

</script>
