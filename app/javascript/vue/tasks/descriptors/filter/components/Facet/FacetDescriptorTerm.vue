<template>
  <FacetContainer>
    <h3>Descriptor</h3>
    <div class="field label-above">
      <label>Term</label>
      <input
        class="full_width"
        type="text"
        placeholder="Type..."
        v-model="params.term"
      >
      <label>
        <input
          v-model="params.term_exact"
          type="checkbox"
        >
        Exact
      </label>
    </div>
    <span class="margin-small-bottom margin-small-top">Term target</span>
    <ul class="no_bullets">
      <li>
        <label>
          <input
            type="radio"
            :value="undefined"
            v-model="params.term_target"
          >
          All
        </label>
      </li>
      <li
        v-for="term in ATTRIBUTES"
        :key="term"
      >
        <label
          class="capitalize"
        >
          <input
            type="radio"
            :value="term"
            v-model="params.term"
          >
          {{ term.replaceAll('_', ' ') }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import { computed } from 'vue'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'

const ATTRIBUTES = [
  'name',
  'short_name',
  'description',
  'description_name',
  'key_name'
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
  set: value => {
    emit('update:modelValue', value)
  }
})

</script>
