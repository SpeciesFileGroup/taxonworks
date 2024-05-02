<template>
  <FacetFileExtension
    v-model="params"
    :extensions="extensions"
  />
  <VBtn
    color="primary"
    medium
    @click="() => emit('filter')"
    class="filter_button"
  >
    Search
  </VBtn>
</template>

<script setup>
import FacetFileExtension from '@/components/Filter/Facets/Document/FacetFileExtension.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const props = defineProps({
  extensions: {
    type: Array,
    required: true
  }
})

const params = defineModel()

const emit = defineEmits(['filter'])
</script>

<style lang="scss" scoped>
  .filter_button {
    margin-top: 1em;
  }
</style>
