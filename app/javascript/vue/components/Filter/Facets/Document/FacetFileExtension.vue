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
          {{ h['extensions'].join(', ') }}
        </label>
      </div>
    </div>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const props = defineProps({
  extensionGroups: {
    type: Array,
    default: []
  }
})

const params = defineModel()

function updateParams(extensionGroup) {
  params.value.file_extension_group = extensionGroup
}
</script>

<style lang="scss" scoped>
.extensions {
  margin-bottom: 1.5em;
}
</style>
