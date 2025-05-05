<template>
  <FacetContainer highlight>
    <h3>Venn</h3>
    <div class="field label-above">
      <label
        ><em
          >Paste the full JSON or browser URL of a query for this filter (the
          "B" query)</em
        >
      </label>
      <input
        class="full_width"
        type="text"
        :value="params.venn"
        @change="(e) => (params.venn = encodeURI(e.target.value))"
      />
      <label>Operation</label>
      <ul class="no_bullets">
        <li>
          <label>
            <input
              type="radio"
              v-model="params.venn_mode"
              :value="undefined"
            />
            None
          </label>
        </li>
        <li
          v-for="(value, key) in VENN_MODES"
          :key="key"
        >
          <label>
            <input
              v-model="params.venn_mode"
              type="radio"
              :value="key"
            />
            {{ value }}
          </label>
        </li>
      </ul>
    </div>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import { computed } from 'vue'

const VENN_MODES = {
  a: 'Exclude (A not B)',
  ab: 'Intersect (found in A & B)',
  b: 'Inverse exclude (B not A)'
}

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get() {
    return props.modelValue
  },

  set(value) {
    emit('update:modelValue', value)
  }
})
</script>
