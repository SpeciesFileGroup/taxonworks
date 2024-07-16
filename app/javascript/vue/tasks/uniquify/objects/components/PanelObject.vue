<template>
  <BlockLayout>
    <template #header>
      <div class="flex-separate middle full_width">
        <h3>Objects</h3>
      </div>
    </template>
    <template #body>
      <ModelSelector v-model="model" />
    </template>
  </BlockLayout>

  <div
    v-if="model"
    class="flexbox gap-medium margin-medium-top"
  >
    <BlockLayout>
      <template #header>
        <h3>Keep</h3>
      </template>
      <template #body>
        <ObjectSelector
          ref="keepRef"
          :title="model"
          :model="model"
          :exclude-ids="[destroyObject?.id, keepObject?.id].filter(Boolean)"
          v-model="keepObject"
        />
        <MetadataCount
          v-if="keepObject"
          class="full_width"
          :global-id="keepObject.global_id"
        />
      </template>
    </BlockLayout>

    <BlockLayout>
      <template #header>
        <h3>Destroy</h3>
      </template>
      <template #body>
        <ObjectSelector
          :title="model"
          :model="model"
          :exclude-ids="[destroyObject?.id, keepObject?.id].filter(Boolean)"
          v-model="destroyObject"
        />
        <MetadataCount
          v-if="destroyObject"
          class="full_width"
          :global-id="destroyObject.global_id"
        />
      </template>
    </BlockLayout>
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

<script setup>
import { ref, nextTick, watch, onMounted } from 'vue'
import { toPascalCase, toSnakeCase } from '@/helpers'
import { RouteNames } from '@/routes/routes.js'
import SetParam from '@/helpers/setParam.js'
import VBtn from '@/components/ui/VBtn/index.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import ObjectSelector from './ObjectSelector.vue'
import MetadataCount from './MetadataCount.vue'
import ModelSelector from './ModelSelector.vue'
import PrewiewMerge from './PreviewMerge.vue'

const model = ref(null)
const destroyObject = ref(null)
const keepObject = ref(null)
const keepRef = ref(null)

watch(model, () => {
  destroyObject.value = null
  keepObject.value = null
})

function flip() {
  const tmp = destroyObject.value

  destroyObject.value = keepObject.value
  keepObject.value = tmp
}

onMounted(() => {
  const urlObj = new URL(window.location)
  const params = new URLSearchParams(urlObj.search)

  params.forEach((value, key) => {
    if (key.endsWith('_id')) {
      model.value = toPascalCase(key.slice(0, -3))

      nextTick(() => {
        keepRef.value.loadObjectById(value)
      })
    }
  })
})

watch(keepObject, (newVal) => {
  if (newVal) {
    const url = new URL(RouteNames.UniquifyObjects, window.location.origin)
    const paramName = toSnakeCase(model.value) + '_id'
    url.searchParams.set(paramName, newVal?.id)
    const newUrl = url.pathname + url.search

    history.pushState(null, null, newUrl)
  } else {
    history.pushState(null, null, RouteNames.UniquifyObjects)
  }
})
</script>
