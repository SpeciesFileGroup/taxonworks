<template>
  <div>
    <div class="news-column">{{ title }}</div>
    <div class="flex-col">
      <NewsCard
        v-for="item in news"
        :key="item.id"
        :news="item"
        @click="() => (currentNew = item)"
      />
    </div>
  </div>
</template>

<script setup>
import { inject } from 'vue'
import NewsCard from './NewsCard.vue'

const currentNew = inject('currentNew')

defineProps({
  news: {
    type: Array,
    required: true
  },

  title: {
    type: String,
    required: true
  }
})
</script>

<style scoped>
.news-column {
  font-size: 1.5rem;
  margin-top: 2rem;
  margin-bottom: 0.5rem;
}
</style>
