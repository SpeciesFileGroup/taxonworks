<template>
  <BlockLayout>
    <template #header>
      <div class="flex-separate middle full_width">
        <h3>Objects</h3>
      </div>
    </template>
    <template #body>
      <ModelSelector v-model="model" />
      <div
        v-if="model"
        class="flexbox gap-medium"
      >
        <div class="panel content">
          <ObjectSelector
            v-model="keepObject"
            :model="model"
          />
          <MetadataCount
            v-if="keepObject"
            :global-id="keepObject.global_id"
          />
        </div>

        <div class="panel content">
          <ObjectSelector
            v-model="destroyObject"
            :model="model"
          />
          <MetadataCount
            v-if="destroyObject"
            :global-id="destroyObject.global_id"
          />
        </div>
      </div>
      <div class="horizontal-left-content middle gap-small margin-medium-top">
        <PrewiewMerge
          :keep-global-id="keepObject?.global_id"
          :remove-global-id="destroyObject?.global_id"
        />
        <VBtn
          color="primary"
          @click="flip"
        >
          Flip
        </VBtn>
      </div>
    </template>
  </BlockLayout>
</template>

<script setup>
import { ref, watch } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import ObjectSelector from './ObjectSelector.vue'
import MetadataCount from './MetadataCount.vue'
import ModelSelector from './ModelSelector.vue'
import PrewiewMerge from './PreviewMerge.vue'

const model = ref(null)
const destroyObject = ref(null)
const keepObject = ref(null)

watch(model, () => {
  destroyObject.value = null
  keepObject.value = null
})

function flip() {
  const tmp = destroyObject.value

  destroyObject.value = keepObject.value
  keepObject.value = tmp
}
</script>
