<template>
  <h1>Content publisher</h1>
  <div>
    <TopicList :topics="topics" />
  </div>
</template>

<script setup>
import { useStore } from './composables/useStore'
import TopicList from './components/Topic/TopicList.vue'

const {
  topics,
  requestTopics
} = useStore()

requestTopics()
</script>
