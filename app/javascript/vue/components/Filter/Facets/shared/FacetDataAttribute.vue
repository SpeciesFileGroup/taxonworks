<template>
  <FacetContainer>
    <h3>Data attributes</h3>
    <label>Predicate</label>
    <SmartSelector
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{ 'type[]': 'Predicate' }"
      get-url="/controlled_vocabulary_terms/"
      model="predicates"
      buttons
      inline
      klass="DataAttribute"
      @selected="(predicate) => addPredicate(predicate, VALUE_OPTION.with)"
    />
    <table
      v-if="predicates.length"
      class="margin-medium-bottom table-striped"
    >
      <thead>
        <tr>
          <th>Predicate</th>
          <th>Value</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="predicate in predicates"
          :key="predicate.id"
        >
          <td>{{ predicate.name }}</td>
          <td>
            <ul class="no_bullets">
              <li
                v-for="(option, key) in VALUE_OPTION"
                :key="key"
              >
                <label>
                  <input
                    :value="option"
                    v-model="predicate.param"
                    type="radio"
                  />
                  {{ key }}
                </label>
              </li>
            </ul>
          </td>
          <td>
            <VBtn
              color="primary"
              circle
              @click="() => removeFromArray(predicates, predicate)"
            >
              <VIcon
                name="trash"
                x-small
              />
            </VBtn>
          </td>
        </tr>
      </tbody>
    </table>
    <label>Value</label>
    <div class="field">
      <textarea
        v-model="inputValue"
        class="full_width"
        rows="5"
      />
      <div class="flex-separate middle">
        <div class="horizontal-left-content middle gap-small">
          <VBtn
            color="primary"
            medium
            @click="() => addValue()"
          >
            Add
          </VBtn>
        </div>
        <label>
          <input
            v-model="params.data_attribute_exact"
            type="checkbox"
          />
          Data attribute exact
        </label>
      </div>
    </div>
    <DisplayList
      :list="params.data_attribute_value"
      :delete-warning="false"
      @delete-index="(index) => params.data_attribute_value.splice(index, 1)"
    />
  </FacetContainer>
</template>

<script setup>
import { computed, ref, watch, onBeforeMount } from 'vue'
import { ControlledVocabularyTerm } from 'routes/endpoints'
import { addToArray, removeFromArray } from 'helpers/arrays.js'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import SmartSelector from 'components/ui/SmartSelector.vue'
import DisplayList from 'components/displayList.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import VBtn from 'components/ui/VBtn/index.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const VALUE_OPTION = {
  with: 'with',
  without: 'without',
  any: 'any'
}

const emit = defineEmits(['update:modelValue'])
const predicates = ref([])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

watch(
  predicates,
  (newVal) => {
    params.value.data_attribute_predicate_id = newVal
      .filter((p) => p.param === VALUE_OPTION.with)
      .map((item) => item.id)
    params.value.any_value_data_attribute = newVal
      .filter((p) => p.param === VALUE_OPTION.any)
      .map((item) => item.id)
    params.value.no_value_data_attribute = newVal
      .filter((p) => p.param === VALUE_OPTION.without)
      .map((item) => item.id)
  },
  { deep: true }
)

watch(
  [
    () => props.modelValue.data_attribute_predicate_id,
    () => props.modelValue.no_value_data_attribute,
    () => props.modelValue.any_value_data_attribute
  ],
  ([newVal, newVal2, newVal3], [oldVal, oldVal2, oldVal3]) => {
    if (
      !newVal?.length &&
      !newVal2?.length &&
      !newVal3?.length &&
      (oldVal?.length || oldVal2?.length || oldVal3?.length)
    ) {
      predicates.value = []
    }
  },
  { deep: true }
)

const inputValue = ref('')

const addValue = () => {
  ;(params.value.data_attribute_value ||= []).push(inputValue.value)

  inputValue.value = ''
}

function addPredicate(p, param) {
  addToArray(predicates.value, {
    id: p.id,
    name: p.name,
    param
  })
}

onBeforeMount(() => {
  const predicateWithValues = params.value.data_attribute_predicate_id || []
  const predicateWithoutValues = params.value.no_value_data_attribute || []
  const predicateAny = params.value.any_value_data_attribute || []
  const predicateIds = [
    ...predicateWithValues,
    ...predicateWithoutValues,
    ...predicateAny
  ]

  if (predicateIds.length) {
    ControlledVocabularyTerm.where({ id: predicateIds }).then(({ body }) => {
      body.forEach((p) => {
        const id = p.id

        if (predicateWithValues.includes(id)) {
          addPredicate(p, VALUE_OPTION.with)
        } else if (predicateWithoutValues.includes(id)) {
          addPredicate(p, VALUE_OPTION.without)
        } else {
          addPredicate(p, VALUE_OPTION.any)
        }
      })
    })
  }
})
</script>
