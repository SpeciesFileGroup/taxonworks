<template>
  <article class="news-card">
    <div class="news-card-type middle margin-small-bottom">
      <VBadge
        class="uppercase"
        :color="newsColors[news.type]"
      >
        {{ news.type }}
      </VBadge>
      <div>{{ timeAgo(news.createdAt) }}</div>
    </div>
    <div class="news-card-title">{{ news.title }}</div>
    <div
      class="news-card-body"
      v-html="news.body"
    />
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
  padding: 1rem 0rem;
  cursor: pointer;
  transition: all 0.3s ease;
  padding-right: 2rem;
}

.news-card:nth-child(2) {
  padding-left: 2rem;
  border-left: 1px solid var(--border-color);
  padding-right: 0rem;
}

.news-card-type {
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 0.5rem;
  text-transform: uppercase;
  font-size: 0.625rem;
  letter-spacing: 0.05em;
}

.news-card-title {
  font-size: 2rem;
  font-weight: bold;
}

.news-card-body {
  font-size: 1rem;
  max-height: 300px;
  min-height: 200px;
  overflow: hidden;
  position: relative;
}

.news-card-body::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  width: 100%;
  height: 60px;
  background: linear-gradient(
    to bottom,
    color-mix(in srgb, var(--bg-color), transparent 100%),
    var(--bg-color)
  );
}
</style>
