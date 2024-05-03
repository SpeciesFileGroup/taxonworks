<template>
  <VSpinner v-if="isLoading" />
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
import VSpinner from '@/components/ui/VSpinner.vue'
import { Document } from '@/routes/endpoints'
import { onMounted, ref } from 'vue'

const props = defineProps({
  onlyIncludeGroups: {
    type: Array,
    default: []
  }
})

const params = defineModel('params')

const extensionGroups = defineModel('extensionGroups')

const isLoading = ref(true)

function updateParams(extensionGroup) {
  params.value.file_extension_group = extensionGroup
}

onMounted(() => {
  Document.file_extensions()
    .then(({ body }) => {
      if (props.onlyIncludeGroups.length) {
        extensionGroups.value = body['extension_groups'].filter(h => {
          return props.onlyIncludeGroups.includes(h['group'])
        })
      } else {
        extensionGroups.value = body['extension_groups']
      }
    })
    .finally(() => {
      isLoading.value = false
    })
})
</script>

<style lang="scss" scoped>
.extensions {
  margin-bottom: 1.5em;
}
</style>
