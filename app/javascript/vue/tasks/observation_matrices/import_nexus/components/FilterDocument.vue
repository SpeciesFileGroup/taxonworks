<template>
  <FacetFileExtension
    v-model="params"
    :extension-groups="filterExtensionsGroup"
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
import FacetFileExtension from './FacetFileExtension.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { computed } from 'vue'

const props = defineProps({
  // All extension groups
  extensionGroups: {
    type: Array,
    required: true
  },
  // The names of the extension groups this filter is filtering for
  filterGroupNames: {
    type: Array,
    default: ['nexus']
  }

})

const emit = defineEmits(['filter'])

const params = defineModel()

const filterExtensionsGroup = computed(() => {
  if (props.extensionGroups == []) {
    return []
  }

  let filterGroups = []
  // Matches any extension
  filterGroups.push(props.extensionGroups.find((h) => h['group'] == ''))
  props.filterGroupNames.forEach((name) => {
    filterGroups.push(
      props.extensionGroups.find((h) => h['group'] == name)
    )
  })

  return filterGroups
})

</script>

<style lang="scss" scoped>
  .filter_button {
    margin-top: 1em;
  }
</style>
