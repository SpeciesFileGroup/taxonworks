<template>
  <div class="task-container">
    <h1>Unify objects</h1>
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
            class="margin-medium-bottom"
            :title="model"
            :model="model"
            :keep="keepObject"
            :exclude-ids="[destroyObject?.id, keepObject?.id].filter(Boolean)"
            v-model="keepObject"
            @close-annotator="
              () => keepMetadataRef.loadMetadata(keepObject.global_id)
            "
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
            ref="destroyRef"
            class="margin-medium-bottom"
            :title="model"
            :model="model"
            :exclude-ids="[destroyObject?.id, keepObject?.id].filter(Boolean)"
            v-model="destroyObject"
            @close-annotator="
              () => destroyMetadataRef.loadMetadata(destroyObject.global_id)
            "
          />
          <MetadataCount
            v-if="destroyObject"
            ref="destroyMetadataRef"
            checkboxes
            :warning="destroyTotal > MAX_TOTAL"
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
        :remove="destroyObject"
        :only="only"
        :disabled="!enablePreview"
        @merge="handleMerge"
      />
      <PrewiewMerge
        :keep="keepObject"
        :remove="destroyObject"
        :only="only"
        :on-merge="handleMerge"
        :disabled="!enablePreview"
      />
      <CompareAttributes
        :keep="keepObject"
        :destroy="destroyObject"
      />
      <VBtn
        color="primary"
        :disabled="!(keepObject || destroyObject)"
        @click="flip"
      >
        Flip
      </VBtn>
      <VBtn
        color="primary"
        @click="
          () => {
            keepObject = null
            destroyObject = null
            keepRef.refresh()
            destroyRef.refresh()
          }
        "
      >
        Reset
      </VBtn>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, nextTick, watch, onMounted } from 'vue'
import { toPascalCase, toSnakeCase, URLParamsToJSON } from '@/helpers'
import { RouteNames } from '@/routes/routes.js'
import ButtonMerge from './components/ButtonMerge.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import ObjectSelector from './components/ObjectSelector.vue'
import MetadataCount from './components/MetadataCount.vue'
import KeepMetadata from './components/KeepMetadata.vue'
import ModelSelector from './components/ModelSelector.vue'
import PrewiewMerge from './components/PreviewMerge.vue'
import CompareAttributes from './components/CompareAttributes.vue'
import { MAP_MODEL } from './constants'
import { ID_PARAM_FOR } from '@/components/radials/filter/constants/idParams'

const MAX_TOTAL = 250

defineOptions({
  name: 'UnifyObjects'
})

const model = ref(null)
const only = ref([])
const destroyObject = ref(null)
const destroyRef = ref(null)
const keepObject = ref(null)
const keepRef = ref(null)
const keepMetadataRef = ref(null)
const destroyMetadataRef = ref(null)

const destroyTotal = computed(() => {
  return getMetadataTotal(destroyObject.value?._metadata)
}
)

const enablePreview = computed(() => {
  return destroyTotal.value <= MAX_TOTAL
})

watch(model, () => {
  destroyObject.value = null
  keepObject.value = null
})

function getMetadataTotal(obj = {}) {
  return Object.values(obj).reduce((acc, curr) => (acc += curr.total), 0)
}

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
  const params = URLParamsToJSON(window.location.href)

  Object.entries(params).forEach(([key, value]) => {
    if (key.endsWith('_id')) {
      const paramIdName = toPascalCase(key.slice(0, -3))
      model.value = MAP_MODEL[paramIdName] || paramIdName

      nextTick(() => {
        if (Array.isArray(value)) {
          const [keepId, destroyId] = value

          if (keepId) {
            keepRef.value.loadObjectById(keepId)
          }
          if (destroyId) {
            destroyRef.value.loadObjectById(destroyId)
          }
        } else {
          keepRef.value.loadObjectById(value)
        }
      })
    }
  })
})

watch(keepObject, (newVal) => {
  if (newVal) {
    const paramName =
      ID_PARAM_FOR[model.value] || toSnakeCase(model.value) + '_id'
    const newUrl = `${RouteNames.UnifyObjects}?${paramName}=${newVal.id}`

    history.pushState(null, null, newUrl)
  } else {
    history.pushState(null, null, RouteNames.UnifyObjects)
  }
})
</script>

<style scoped>
.task-container {
  width: 1240px;
  margin: 0 auto;
}
</style>
