<template>
  <h1>Content publisher</h1>
  <div>
    <TopicList :topics="topics" />
    <VSpinner
      v-if="isLoading"
      full-screen
    />
  </div>
</template>

<script setup>
import { useStore } from './composables/useStore'
import TopicList from './components/Topic/TopicList.vue'
import VSpinner from 'components/spinner.vue'

const {
  topics,
  requestTopics,
  isLoading
} = useStore()

requestTopics()
</script>
