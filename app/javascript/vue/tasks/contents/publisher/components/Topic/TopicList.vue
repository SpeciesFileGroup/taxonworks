<template>
  <div>
    <TopicItem
      v-for="({ published, unpublished, topic_id }, name) in topics"
      :key="topic_id"
      class="margin-small-bottom"
      :published="published"
      :unpublished="unpublished"
      :name="name"
      :topic-id="topic_id"
    />
  </div>
</template>

<script setup>
import TopicItem from './TopicItem.vue'

defineProps({
  topics: {
    type: Object,
    default: () => ({})
  }
})
</script>
