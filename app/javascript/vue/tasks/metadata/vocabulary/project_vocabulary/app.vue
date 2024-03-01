<template>
  <h1>Project vocabulary</h1>
  <VSpinner
    v-if="isLoading"
    full-screen
  />
  <div class="horizontal-left-content align-start gap-medium">
    <div class="panel content">
      <PanelSettings v-model="parameters" />
      <VBtn
        color="primary"
        medium
        :disabled="validate"
        @click="getWords"
      >
        Generate word cloud
      </VBtn>
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
import { Metadata } from '@/routes/endpoints'
import { computed, ref } from 'vue'
import VueWordCloud from 'vuewordcloud'
import PanelSettings from './components/PanelSettings.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const words = ref([])
const isLoading = ref(false)
const parameters = ref(initParameters())
const validate = computed(
  () => !(parameters.value.model && parameters.value.attribute)
)

function getWords() {
  isLoading.value = true
  Metadata.vocabulary(parameters.value)
    .then(({ body }) => {
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
</script>

<style>
.word-cloud-container {
  height: calc(100vh - 220px);
  width: 100%;
  box-sizing: border-box;
}
</style>
