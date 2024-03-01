<template>
  <h1>Project vocabulary</h1>
  <VSpinner
    v-if="isLoading"
    full-screen
  />
  <div class="horizontal-left-content align-start gap-medium task-container">
    <div class="flex-col gap-medium full_height">
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
          Generate word cloud
        </VBtn>
      </div>
      <div
        v-if="words.length"
        class="overflow-y-auto"
      >
        <TableWords
          class="full_width"
          :list="words"
        />
      </div>
    </div>
    <div class="word-cloud-container panel padding-medium">
      <VueWordCloud
        class="full_width full_height"
        :words="words"
      />
    </div>
  </div>
</template>

<script setup>
import VSpinner from '@/components/ui/VSpinner.vue'
import { RouteNames } from '@/routes/routes'
import { setParam } from '@/helpers'
import { Metadata } from '@/routes/endpoints'
import { computed, ref, onBeforeMount } from 'vue'
import VueWordCloud from 'vuewordcloud'
import PanelSettings from './components/PanelSettings.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import TableWords from './components/TableWords.vue'
import { URLParamsToJSON } from '@/helpers/url/parse'

const words = ref([])
const isLoading = ref(false)
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
</style>
