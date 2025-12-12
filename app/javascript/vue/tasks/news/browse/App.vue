<template>
  <VSpinner
    v-if="isLoading"
    full-screen
  />
  <NewsViewer
    v-if="currentNews"
    :news="currentNews"
    @close="() => (currentNews = undefined)"
  />
  <template v-else>
    <div class="newspapper-header">
      <VTabs
        class="capitalize"
        :tabs="newspapperTypes"
        v-model="newspapperType"
      />
      <NewsCategories
        v-if="newspapperType"
        :types="types[newspapperType]"
        v-model="currentType"
      />
      <a :href="RouteNames.NewNews">New</a>
    </div>
    <NewsContainer
      :news="news"
      :type="currentType"
    />
  </template>
</template>

<script setup>
import { ref, provide, onBeforeMount, watch } from 'vue'
import { setParam, URLParamsToJSON, utcToLocal, formatDate } from '@/helpers'
import { RouteNames } from '@/routes/routes'
import { News } from '@/routes/endpoints'
import { usePopstateListener } from '@/composables'
import NewsContainer from './components/NewsContainer.vue'
import NewsCategories from './components/NewsCategories.vue'
import NewsViewer from './components/Viewer/NewsViewer.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VTabs from './components/Tabs.vue'

defineOptions({
  name: 'BrowseNews'
})

const NEWSPAPPER_ADMINISTRATION = 'administration'

const newspapperType = ref('')
const newspapperTypes = ref([])
const types = ref([])
const currentType = ref('All')
const news = ref([])
const currentNews = ref()
const isLoading = ref()

provide('currentNew', currentNews)

watch([currentNews, currentType, newspapperType], () => {
  setParam(RouteNames.BrowseNews, {
    news_id: currentNews.value?.id,
    category: currentType.value,
    newspapper: newspapperType.value
  })
})

function makeNews(data) {
  return {
    id: data.id,
    body: data.body_html,
    admin: data.type.includes('Administration'),
    type: data.type.split('::')[2],
    title: data.title,
    creator: data.creator,
    createdAt: formatDate(new Date(data.created_at))
  }
}

function loadFromUrlParam() {
  const {
    news_id: newsId,
    category,
    newspapper
  } = URLParamsToJSON(location.href)

  if (newspapper) {
    newspapperType.value = newspapper
  }

  if (category) {
    currentType.value = category
  }

  if (newsId) {
    News.find(newsId).then(({ body }) => {
      currentNews.value = makeNews(body)
    })
  } else {
    currentNews.value = undefined
  }
}

onBeforeMount(loadFromUrlParam)
usePopstateListener(loadFromUrlParam)

News.types()
  .then(({ body }) => {
    const keys = Object.keys(body)
    const items = keys.reduce((acc, curr) => {
      const values = Object.values(body[curr])
      acc[curr] = ['All', ...values.map((type) => type.split('::')[2])]

      return acc
    }, {})
    newspapperTypes.value = keys
    newspapperType.value = keys[0]
    types.value = items
  })
  .catch(() => {})

watch(newspapperType, (newVal) => {
  const request =
    newVal === NEWSPAPPER_ADMINISTRATION ? News.administration() : News.all()

  isLoading.value = true

  request
    .then(({ body }) => {
      news.value = body.reverse().map(makeNews)
    })
    .catch(() => {})
    .finally(() => {
      isLoading.value = false
    })
})
</script>

<style scoped>
.newspapper-header {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  max-width: 1280px;
  align-items: center;
  margin: 0 auto;
  padding-top: 2rem;
}
</style>
