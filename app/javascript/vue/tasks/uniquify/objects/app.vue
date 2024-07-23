<template>
  <div class="task-container">
    <h1>Uniquify objects</h1>
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
            :keep="keepObject"
            :exclude-ids="[destroyObject?.id, keepObject?.id].filter(Boolean)"
            v-model="keepObject"
          />
          <KeepMetadata
            v-if="keepObject"
            ref="keepMetadataRef"
            class="full_width"
            :merge-item="destroyObject"
            :only="only"
            v-model="keepObject"
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
            checkboxes
            class="full_width"
            v-model:only="only"
            v-model="destroyObject"
          />
        </template>
      </BlockLayout>
    </div>

    <div class="horizontal-left-content middle gap-small margin-medium-top">
      <ButtonMerge
        :keep-global-id="keepObject?.global_id"
        :remove-global-id="destroyObject?.global_id"
        :only="only"
        @merge="handleMerge"
      />
      <PrewiewMerge
        :keep="keepObject"
        :remove="destroyObject"
        :only="only"
        :on-merge="handleMerge"
      />
      <VBtn
        color="primary"
        @click="flip"
      >
        Flip
      </VBtn>
    </div>
  </div>
</template>

<script setup>
import { ref, nextTick, watch, onMounted } from 'vue'
import { toPascalCase, toSnakeCase } from '@/helpers'
import { RouteNames } from '@/routes/routes.js'
import ButtonMerge from './components/ButtonMerge.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import ObjectSelector from './components/ObjectSelector.vue'
import MetadataCount from './components/MetadataCount.vue'
import KeepMetadata from './components/KeepMetadata.vue'
import ModelSelector from './components/ModelSelector.vue'
import PrewiewMerge from './components/PreviewMerge.vue'

defineOptions({
  name: 'UniquifyObjects'
})

const model = ref(null)
const only = ref([])
const destroyObject = ref(null)
const keepObject = ref(null)
const keepRef = ref(null)
const keepMetadataRef = ref(null)

watch(model, () => {
  destroyObject.value = null
  keepObject.value = null
})

function flip() {
  const tmp = destroyObject.value

  destroyObject.value = keepObject.value
  keepObject.value = tmp
}

function handleMerge() {
  destroyObject.value = null
  keepMetadataRef.value.loadMetadata(keepObject.value.global_id)
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
    const paramName = toSnakeCase(model.value) + '_id'
    const newUrl = `${RouteNames.UniquifyObjects}?${paramName}=${newVal.id}`

    history.pushState(null, null, newUrl)
  } else {
    history.pushState(null, null, RouteNames.UniquifyObjects)
  }
})
</script>

<style scoped>
.task-container {
  width: 1240px;
  margin: 0 auto;
}
</style>
