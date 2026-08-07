<template>
  <FacetContainer>
    <h3>Type</h3>
    <div class="field">
      <ul class="no_bullets">
        <li
          v-for="(type, label) in TYPE_LIST"
          :key="type"
        >
          <label class="capitalize">
            <input
              type="radio"
              :value="type"
              name="nomenclature-code-type"
              v-model="params.collection_object_type"
            />
            {{ label }}
          </label>
        </li>
      </ul>
    </div>
  </FacetContainer>
</template>

<script setup>
import { computed } from 'vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const TYPE_LIST = {
  All: undefined,
  Specimen: 'Specimen',
  Lot: 'Lot',
  'Ranged Lot': 'RangedLot'
}

const emit = defineEmits(['update:modelValue'])
</script>
