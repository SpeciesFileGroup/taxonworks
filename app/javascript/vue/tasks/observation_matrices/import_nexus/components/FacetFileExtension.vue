<template>
  <FacetContainer>
    <h3>File extensions</h3>
    <div class="extensions">
      <div
        v-for="h in extensionGroups"
        :key="h['group']"
      >
        <label @click="() => updateParams(h['group'])">
          <input
            type="radio"
            :value="h['group']"
            :checked="h['group'] == ''"
            name="extensions"
          />
          {{ h['extensions'].map((hh => hh.extension)).join(', ') }}
        </label>
      </div>
    </div>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const props = defineProps({
  // An example extension group:
  // {
  //   group: 'nexus',
  //   extensions: [
  //     {
  //       extension: '.nex',
  //       content_type: 'text/plain'
  //     },
  //     {
  //       extension: '.nxs',
  //       content_type: 'text/plain'
  //     }
  //   ]
  // }
  extensionGroups: {
    type: Array,
    default: []
  }
})

const params = defineModel()

function updateParams(extensionGroupName) {
  params.value.file_extension_group_name = extensionGroupName
}
</script>

<style lang="scss" scoped>
.extensions {
  margin-bottom: 1.5em;
}
</style>
