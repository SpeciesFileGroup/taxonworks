<template>
  <VSpinner
    v-if="isLoading"
    full-screen
  />
  <NewsViewer
    v-if="currentNew"
    :news="currentNew"
    @click="() => (currentNew = undefined)"
  />
  <template v-else>
    <NewsCategories
      :types="types"
      v-model="currentType"
    />
    <NewsContainer
      :news="news"
      :type="currentType"
    />
  </template>
</template>

<script setup>
import { ref, provide, onBeforeMount, watch } from 'vue'
import { setParam, URLParamsToJSON } from '@/helpers'
import { RouteNames } from '@/routes/routes'
import { News } from '@/routes/endpoints'
import { usePopstateListener } from '@/composables'
import NewsContainer from './components/NewsContainer.vue'
import NewsCategories from './components/NewsCategories.vue'
import NewsViewer from './components/Viewer/NewsViewer.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const types = ref([])
const currentType = ref('All')
const news = ref([])
const currentNew = ref()
const isLoading = ref(true)

provide('currentNew', currentNew)

watch(currentNew, (newVal = {}) => {
  setParam(RouteNames.BrowseNews, 'news_id', newVal.id)
})

function makeNews(data) {
  return {
    id: data.id,
    body: data.body_html,
    type: data.type.split('::')[2],
    title: data.title,
    createdAt: data.created_at
  }
}

usePopstateListener(() => {
  const { news_id: newsId } = URLParamsToJSON(location.href)

  if (newsId) {
    News.find(newsId).then(({ body }) => {
      currentNew.value = makeNews(body)
    })
  }
})

onBeforeMount(() => {
  const params = URLParamsToJSON(window.location.href)
  const newsId = params.news_id

  if (newsId) {
    News.find(newsId).then(({ body }) => {
      currentNew.value = makeNews(body)
    })
  }
})

News.types()
  .then(({ body }) => {
    const arrTypes = Object.values(body.project)

    types.value = ['All', ...arrTypes.map((type) => type.split('::')[2])]
  })
  .catch(() => {})

News.all()
  .then(({ body }) => {
    news.value = body.reverse().map(makeNews)
  })
  .catch(() => {})
  .finally(() => {
    isLoading.value = false
  })
</script>
