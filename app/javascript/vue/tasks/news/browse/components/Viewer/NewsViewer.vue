<template>
  <div class="news-viewer">
    <VBadge
      class="margin-small-bottom"
      :color="newsColors[news.type]"
      >{{ news.type }}</VBadge
    >
    <div
      class="news-viewer-title"
      v-text="news.title"
    />
    <div v-html="news.body" />
    <NewsViewerBack
      class="margin-xlarge-top"
      @click="() => emit('close')"
    />
  </div>
</template>

<script setup>
import newsColors from '../../constants/newsColors'
import NewsViewerBack from './NewsViewerBack.vue'
import VBadge from '@/components/ui/VBadge/VBadge.vue'

defineProps({
  news: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['close'])
</script>

<style scoped>
.news-viewer {
  width: 1280px;
  margin: 0 auto;
  padding: 3rem 0rem;
}
.news-viewer-title {
  font-family: serif;
  font-size: 2rem;
  margin-bottom: 1.5rem;
}

.news-viewer-body {
  font-size: 1.1rem;
}
</style>
