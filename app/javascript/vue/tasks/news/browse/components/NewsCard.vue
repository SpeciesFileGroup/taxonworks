<template>
  <article class="news-card">
    <div class="news-card-time-ago">{{ timeAgo(news.createdAt) }}</div>
    <div>
      <VBadge
        class="margin-small-bottom uppercase"
        :color="newsColors[news.type]"
      >
        {{ news.type }}
      </VBadge>

      <div class="news-card-title">{{ news.title }}</div>
      <div
        class="news-card-body"
        v-html="news.body"
      />
    </div>
  </article>
</template>

<script setup>
import { timeAgo } from '@/helpers'
import VBadge from '@/components/ui/VBadge/VBadge.vue'
import newsColors from '../constants/newsColors'

const props = defineProps({
  news: {
    type: Object,
    required: true
  }
})
</script>

<style scoped>
.news-card {
  display: flex;
  flex-direction: row;
  border-bottom: 1px solid var(--panel-border-color);
  cursor: pointer;
  padding: 1.5rem 0rem;
  gap: 4rem;
  transition: all 0.3s ease;
}

.news-card-title {
  font-size: 1.5rem;
  font-weight: bold;
  font-family: serif;
}

.news-card-time-ago {
  text-transform: uppercase;
  font-size: 0.625rem;
  letter-spacing: 0.05em;
}

.news-card-body {
  max-width: 1100px;
  white-space: nowrap;
  text-overflow: ellipsis;
  overflow: hidden;
  opacity: 0.75;
}

.news-card-body * {
  display: inline;
  white-space: nowrap !important;
}
</style>
