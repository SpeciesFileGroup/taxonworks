<template>
  <div class="app-container">
    <VSpinner
      v-if="isSaving"
      legend="Saving..."
    />
    <BlockLayout>
      <template #header>
        <h3>Create news</h3>
      </template>
      <template #options>
        <div class="flex-row gap-small">
          <VRecent
            v-if="projectId"
            project
            title="Recent project news"
            :service="News.where"
            @edit="setNews"
          />
          <VRecent
            v-if="isAdministrator"
            title="Recent administration news"
            :service="News.administration"
            @edit="setNews"
          />
        </div>
      </template>
      <template #body>
        <VForm v-model="news" />
        <div class="flex-row gap-small">
          <VBtn
            color="create"
            medium
            :disabled="!isSaveAvailable"
            @click="save"
          >
            {{ news.id ? 'Save' : 'Create' }}
          </VBtn>
          <VBtn
            color="primary"
            medium
            @click="reset"
          >
            New
          </VBtn>
        </div>
      </template>
    </BlockLayout>
  </div>
</template>

<script setup>
import { ref, computed, onBeforeMount, watch } from 'vue'
import { News } from '@/routes/endpoints'
import { getCurrentProjectId, isCurrentUserAdministrator } from '@/helpers'
import { makeNews, makeNewsPayload } from './adapters'
import { usePopstateListener } from '@/composables'
import { RouteNames } from '@/routes/routes'
import { URLParamsToJSON, setParam } from '@/helpers'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import VForm from './components/Form.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VRecent from './components/Recent.vue'

defineOptions({
  name: 'NewsAdministration'
})

const news = ref(makeNews())
const isSaving = ref(false)
const projectId = ref(getCurrentProjectId())
const isAdministrator = ref(isCurrentUserAdministrator())

const isSaveAvailable = computed(
  () => news.value.type && news.value.title && news.value.body
)

async function save() {
  try {
    const newsId = news.value.id
    const payload = {
      news: makeNewsPayload(news.value)
    }

    isSaving.value = true

    if (newsId) {
      await News.update(newsId, payload)
    } else {
      await News.create(payload)
    }

    TW.workbench.alert.create('News was successfully saved.', 'notice')
  } catch {
  } finally {
    isSaving.value = false
  }
}

function setNews(value) {
  news.value = value
}

function reset() {
  news.value = makeNews()
}

watch(
  () => news.value.id,
  (id) => {
    setParam(RouteNames.NewNews, 'news_id', id)
  }
)

function loadFromUrlParam() {
  const { news_id: newsId } = URLParamsToJSON(location.href)

  if (newsId) {
    News.find(newsId).then(({ body }) => {
      news.value = makeNews(body)
    })
  }
}

usePopstateListener(loadFromUrlParam)
onBeforeMount(loadFromUrlParam)
</script>

<style scoped>
.app-container {
  width: 1240px;
  margin: 0rem auto;
  margin-top: 2rem;
}
</style>
