<template>
  <div class="news-container">
    <div class="news-container-newest">
      <NewsNewestNews
        v-for="news in newsList.newest"
        :key="type"
        :news="news"
        @click="() => (currentNew = news)"
      />
    </div>
    <template v-if="newsList.news.length">
      <hr class="divisor full_width" />
      <NewsColumn
        :news="newsList.news"
        title="All News"
      />
    </template>
  </div>
</template>

<script setup>
import { computed, inject } from 'vue'
import NewsColumn from './NewsColumn.vue'
import NewsNewestNews from './NewsNewestNews.vue'

const props = defineProps({
  news: {
    type: Array,
    required: true
  },

  type: {
    type: String,
    required: true,
    default: 'All'
  }
})

const currentNew = inject('currentNew')

const list = computed(() =>
  props.type === 'All'
    ? props.news
    : props.news.filter((item) => item.type.includes(props.type))
)

const newsList = computed(() => {
  const news = list.value.slice()
  const newest = news.splice(0, 2)

  return {
    newest,
    news
  }
})
</script>

<style scoped>
.news-container {
  display: grid;
  max-width: 1280px;
  margin: 0 auto;
  gap: 1px;
  padding: 2rem 3rem;
}

.news-container-newest {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  padding-bottom: 2rem;
}
</style>
