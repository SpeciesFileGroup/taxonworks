<template>
  <FacetFileExtension
    v-model="params"
    :extension-groups="nexusExtensionsGroup"
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
  extensionGroups: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['filter'])

const params = defineModel()

const nexusExtensionsGroup = computed(() => {
  if (props.extensionGroups == []) {
    return []
  } else {
    const anyGroup = props.extensionGroups.find((h) => h['group'] == '')
    const nexusGroup =
      props.extensionGroups.find((h) => h['group'] == 'nexus')

    return [anyGroup, nexusGroup]
  }
})

</script>

<style lang="scss" scoped>
  .filter_button {
    margin-top: 1em;
  }
</style>
