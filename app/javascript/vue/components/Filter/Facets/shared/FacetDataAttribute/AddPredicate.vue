<template>
  <div>
    <label>Predicate</label>
    <SmartSelector
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{ 'type[]': 'Predicate' }"
      get-url="/controlled_vocabulary_terms/"
      model="predicates"
      buttons
      inline
      klass="DataAttribute"
      @selected="(p) => (predicate = p)"
    />
    <SmartSelectorItem
      :item="predicate"
      label="name"
      @unset="
        () => {
          predicate = undefined
        }
      "
    />
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
            :disabled="!predicate"
            @click="() => addPredicate({ any: false })"
          >
            Add
          </VBtn>
          <VBtn
            color="primary"
            medium
            :disabled="!predicate"
            @click="() => addPredicate({ any: true, text: '' })"
          >
            Any
          </VBtn>
        </div>
        <label>
          <input
            v-model="exact"
            type="checkbox"
          />
          Exact
        </label>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import SmartSelector from 'components/ui/SmartSelector.vue'
import SmartSelectorItem from 'components/ui/SmartSelectorItem.vue'
import VBtn from 'components/ui/VBtn/index.vue'

const emit = defineEmits(['add'])
const inputValue = ref('')
const predicate = ref()
const exact = ref(false)

function addPredicate(params) {
  const data = {
    id: predicate.value.id,
    name: predicate.value.name,
    text: inputValue.value,
    exact: exact.value,
    ...params
  }

  inputValue.value = ''
  predicate.value = undefined

  emit('add', data)
}
</script>
