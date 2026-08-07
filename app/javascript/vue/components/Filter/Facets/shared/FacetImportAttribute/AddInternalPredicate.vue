<template>
  <div>
    <div class="field">
      <label>Predicate</label>
      <VAutocomplete
        url="/data_attributes/import_predicate_autocomplete"
        param="term"
        placeholder="Type a predicate..."
        clear-after
        @get-item="
          (item) => {
            internalPredicate = item
          }
        "
      />

      <SmartSelectorItem
        :item="internalPredicate"
        :label="false"
        @unset="
          () => {
            internalPredicate = undefined
          }
        "
      />
    </div>
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
            :disabled="!internalPredicate || !inputValue.length"
            @click="() => addInternalAttribute({ any: false })"
          >
            Add
          </VBtn>
          <VBtn
            color="primary"
            medium
            :disabled="!internalPredicate || !!inputValue.length"
            @click="() => addInternalAttribute({ any: true, text: '' })"
          >
            Any
          </VBtn>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const emit = defineEmits(['add'])
const inputValue = ref('')
const internalPredicate = ref('')

function addInternalAttribute(params) {
  const data = {
    name: internalPredicate.value,
    text: inputValue.value,
    exact: false,
    ...params
  }

  inputValue.value = ''
  internalPredicate.value = undefined

  emit('add', data)
}
</script>
