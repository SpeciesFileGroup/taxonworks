<template>
  <div class="news-viewer">
    <div class="flex flex-separate middle">
      <VBadge
        class="margin-small-bottom uppercase"
        :color="newsColors[news.type]"
        >{{ news.type }}</VBadge
      >
      <VBtn
        v-if="isEditAvailable"
        color="primary"
        circle
        :href="`${RouteNames.NewNews}?news_id=${props.news.id}`"
      >
        <VIcon
          name="pencil"
          x-small
        />
      </VBtn>
    </div>
    <div
      class="news-viewer-title"
      v-text="news.title"
    />
    <div>
      <div class="news-meta">{{ news.creator }} — {{ news.createdAt }}</div>
    </div>
    <div v-html="news.body" />
    <NewsViewerBack
      class="margin-xlarge-top"
      @click="() => emit('close')"
    />
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { isCurrentUserAdministrator } from '@/helpers'
import newsColors from '../../constants/newsColors'
import NewsViewerBack from './NewsViewerBack.vue'
import VBadge from '@/components/ui/VBadge/VBadge.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { RouteNames } from '@/routes/routes'

const props = defineProps({
  news: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['close'])
const isAdmin = isCurrentUserAdministrator()

const isEditAvailable = computed(() => {
  return isAdmin || !props.news.admin
})
</script>

<style scoped>
.news-viewer {
  width: 1280px;
  margin: 0 auto;
  padding: 3rem 0rem;
}
.news-viewer-title {
  font-weight: bold;
  font-size: 2rem;
  margin-bottom: 0.3rem;
}

.news-viewer-body {
  font-size: 1.1rem;
}

.news-meta {
  color: var(--text-muted-color);
  font-size: 0.9rem;
  margin-bottom: 2rem;
}
</style>
