<template>
  <h1>Project vocabulary</h1>
  <VSpinner
    v-if="isLoading"
    full-screen
  />
  <div class="horizontal-left-content align-start gap-medium task-container">
    <div class="flex-col gap-medium full_height settings-panel">
      <div class="panel content">
        <PanelSettings
          v-model="parameters"
          class="margin-medium-bottom"
        />
        <VBtn
          color="primary"
          medium
          :disabled="!validate"
          @click="getWords"
        >
          Show records
        </VBtn>
      </div>
      <PanelLinks
        v-if="words.length"
        :model="parameters.model"
        :attribute="parameters.attribute"
      />
      <div
        v-if="words.length"
        class="overflow-y-auto"
      >
        <TableWords
          class="full_width"
          v-model="words"
          @select="openTask"
        />
      </div>
    </div>
    <div class="word-cloud-container panel padding-medium">
      <VSpinner
        v-if="isGeneratingCloud"
        legend="Generating word cloud..."
      />
      <VueWordCloud
        class="full_width full_height"
        :animation-enter="['bounceIn', 'bounceOut']"
        :words="words"
        :font-size-ratio="1 / 20"
        :spacing="1 / 4"
        @update:progress="updateLoadState"
      >
        <template #default="{ text, weight }">
          <div
            :title="weight"
            :class="[
              'text-body-color',
              TASK[parameters.model] && 'cursor-pointer link'
            ]"
            @click="() => openTask(text)"
          >
            {{ text }}
          </div>
        </template>
      </VueWordCloud>
    </div>
  </div>
</template>

<script setup>
import { URLParamsToJSON } from '@/helpers/url/parse'
import { TASK } from './constants/links'
import { RouteNames } from '@/routes/routes'
import { setParam, toPascalCase } from '@/helpers'
import { Metadata } from '@/routes/endpoints'
import { computed, ref, onBeforeMount, watch } from 'vue'
import { useQueryParam } from '@/tasks/data_attributes/field_synchronize/composables/useQueryParam.js'
import VSpinner from '@/components/ui/VSpinner.vue'
import VueWordCloud from 'vuewordcloud'
import PanelSettings from './components/PanelSettings.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import TableWords from './components/TableWords.vue'
import PanelLinks from './components/PanelLinks.vue'
import qs from 'qs'

const LIMIT = 100

defineOptions({
  name: 'ProjectVocabulary'
})

const words = ref([])
const isLoading = ref(false)
const isGeneratingCloud = ref(false)
const parameters = ref(initParameters())
const validate = computed(
  () => parameters.value.model && parameters.value.attribute
)

function getWords() {
  isLoading.value = true
  Metadata.vocabulary(parameters.value)
    .then(({ body }) => {
      setParam(RouteNames.ProjectVocabulary, parameters.value, null, true)
      words.value = Object.entries(body)
    })
    .catch(() => {})
    .finally(() => {
      isLoading.value = false
    })
}

function initParameters() {
  return {
    limit: LIMIT
  }
}

onBeforeMount(() => {
  let urlParams = URLParamsToJSON(window.location.href)

  const { queryParam, queryValue } = useQueryParam()
  urlParams[queryParam.value] = { ...queryValue.value }

  if (Object.keys(urlParams).length) {
    processUrlParams(urlParams)
    if (validate.value) {
      getWords()
    }
  }
})

function processUrlParams(urlParams) {
  let updated = false
  const keys = Object.keys(urlParams)
  if (!keys.includes('limit')) {
    urlParams.limit = LIMIT
    updated = true
  }

  if (!keys.includes('model')) {
    // Get model name from something like
    // otu_query[otu_id][]=1&otu_query[otu_id][]=2
    for (const key of keys) {
      const match = key.match(/^([\w]+)_query/)
      if (match[1]) {
        urlParams.model = toPascalCase(match[1])
        updated = true
        break
      }
    }
  }

  parameters.value = urlParams
  if (updated) {
    // Note: this may drop a long *_query: { *_id: [...] } param from the url,
    // but we'll still be using it to get the project vocabulary (via
    // parameters).
    setParam(RouteNames.ProjectVocabulary, parameters.value, undefined, true)
  }
}

function updateLoadState(e) {
  if (e) {
    const isProcessing = e.completedWords !== e.totalWords

    isGeneratingCloud.value = isProcessing
  } else {
    isGeneratingCloud.value = false
  }
}

function openTask(word) {
  const task = TASK[parameters.value.model]
  const { attribute } = parameters.value

  if (task) {
    const parameter = task.arrarProperties?.includes(attribute)
      ? `${attribute}[]`
      : attribute

    window.open(`${task.url}?${parameter}=${word}`, '_blank')
  }
}

function clearUrlQueryArray() {
  for (const key of Object.keys(parameters.value)) {
    if (key.endsWith('_query')) {
      delete parameters.value[key]

      const queryString = qs.stringify(parameters.value, {
        arrayFormat: 'brackets'
      })

      const url = new URL(window.location)
      url.search = queryString
      window.history.replaceState(null, '', url)
    }
  }
}

watch(
  () => parameters.value.model,
  (newVal, oldVal) => {
    if (oldVal && oldVal != newVal) {
      clearUrlQueryArray()
    }
  }
)

watch(
  parameters,
  () => {
    words.value = []
  },
  { deep: true }
)
</script>

<style scoped>
.task-container {
  height: calc(100vh - 200px);
  max-height: calc(100vh - 200px);
}
.word-cloud-container {
  width: 100%;
  height: 100%;
  box-sizing: border-box;
}

.settings-panel {
  width: 400px;
  max-width: 400px;
}
.text-body-color {
  color: var(--text-color);
}
.link {
  color: var(--color-primary);
}
</style>
