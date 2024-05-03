<template>
  <FacetFileExtension
    v-model:params="params"
    v-model:extension-groups="extensionGroups"
    :only-include-groups="['', 'nexus']"
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

const emit = defineEmits(['filter'])

const params = defineModel('params')
const extensionGroups = defineModel('extensionGroups')

</script>

<style lang="scss" scoped>
  .filter_button {
    margin-top: 1em;
  }
</style>
