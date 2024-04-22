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
            :class="TASK[parameters.model] && 'cursor-pointer link'"
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
import { setParam } from '@/helpers'
import { Metadata } from '@/routes/endpoints'
import { computed, ref, onBeforeMount, watch } from 'vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VueWordCloud from 'vuewordcloud'
import PanelSettings from './components/PanelSettings.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import TableWords from './components/TableWords.vue'

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
      setParam(RouteNames.ProjectVocabulary, parameters.value)
      words.value = Object.entries(body)
    })
    .catch(() => {})
    .finally(() => {
      isLoading.value = false
    })
}

function initParameters() {
  return {
    limit: 100
  }
}

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(window.location.href)

  if (Object.keys(urlParams).length) {
    parameters.value = urlParams

    if (validate.value) {
      getWords()
    }
  }
})

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

.link {
  color: var(--color-primary);
}
</style>
