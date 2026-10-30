<template>
  <FacetContainer>
    <h3
      data-help="Only items placed directly in the container are counted. Containers without size are never full."
    >
      Fill state
    </h3>
    <ul class="no_bullets">
      <li
        v-for="option in OPTIONS"
        :key="option.label"
      >
        <label>
          <input
            type="radio"
            name="container-fill-state"
            :checked="selectedLabel === option.label"
            @change="() => setFillState(option)"
          />
          {{ option.label }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import { computed } from 'vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const OPTIONS = [
  { label: 'Any', empty: undefined, full: undefined },
  { label: 'Empty', empty: true, full: undefined },
  { label: 'Full', empty: undefined, full: true },
  { label: 'Populated', empty: false, full: false }
]

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const selectedLabel = computed(
  () =>
    OPTIONS.find(
      (option) =>
        String(option.empty) === String(params.value.empty) &&
        String(option.full) === String(params.value.full)
    )?.label
)

function setFillState({ empty, full }) {
  params.value.empty = empty
  params.value.full = full
}
</script>
