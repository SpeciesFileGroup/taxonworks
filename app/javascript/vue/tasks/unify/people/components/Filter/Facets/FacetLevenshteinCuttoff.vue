<template>
  <FacetContainer v-help.filter.levenshtein>
    <h3>Levenshtein cuttoff</h3>
    <datalist id="days">
      <option
        v-for="n in 7"
        :key="n"
        :value="n - 1"
      />
    </datalist>
    <input
      type="range"
      list="days"
      min="0"
      max="6"
      step="0"
      v-model.number="levenshteinCuttoff"
    />
    <div class="options-label">
      <span
        :key="n"
        v-for="n in 7"
        v-html="n - 1"
      />
    </div>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import { computed } from 'vue'

const params = defineModel({
  type: Object,
  required: true
})

const levenshteinCuttoff = computed({
  get() {
    return params.value.levenshtein_cuttoff || 0
  },
  set(value) {
    params.value.levenshtein_cuttoff = value === 0 ? undefined : value
  }
})
</script>

<style lang="scss" scoped>
.options-label {
  display: flex;
  width: 268px;
  padding: 0 19px;
  margin-top: -10px;
  justify-content: space-between;
}
datalist {
  display: flex;
  justify-content: space-between;
  margin-top: -23px;
  padding-top: 0px;
  width: 300px;
}
input[type='range'] {
  width: 300px;
}
</style>
