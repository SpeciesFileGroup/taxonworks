<template>
  <FacetContainer>
    <h3>Taxon</h3>
    <div class="field">
      <label>Name</label>
      <input
        type="text"
        placeholder="Name"
        class="full_width"
        v-model="params.name"
      >
    </div>
    <div class="field">
      <label>Author</label>
      <input
        type="text"
        class="full_width"
        placeholder="Author"
        v-model="params.author"
      >
    </div>
    <div class="field">
      <label>Year</label>
      <input
        class="field-year"
        type="text"
        placeholder="Year"
        v-model="params.year"
      >
    </div>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import { computed, onBeforeMount } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'

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

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)

  params.value.name = urlParams.name
  params.value.author = urlParams.author
  params.value.year = urlParams.year
})
</script>

<style lang="scss" scoped>
  .field {
    label {
      display: block;
    }
  }
  .field-year {
    width: 60px;
  }

</style>
