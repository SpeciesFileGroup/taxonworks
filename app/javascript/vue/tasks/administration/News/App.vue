<template>
  <div class="app-container">
    <VSpinner
      v-if="isSaving"
      legend="Saving..."
    />
    <BlockLayout>
      <template #header>
        <h3>Administration News</h3>
      </template>
      <template #body>
        <VForm v-model="news" />
        <div class="flex-row gap-small">
          <VBtn
            color="create"
            medium
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
    <VList
      class="margin-medium-top"
      :list="list"
      @edit="(item) => (news = { ...item })"
      @remove="removeNews"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { News } from '@/routes/endpoints'
import { addToArray, removeFromArray } from '@/helpers'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import VForm from './components/Form.vue'
import VList from './components/List.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

defineOptions({
  name: 'NewsAdministration'
})

const list = ref([])
const news = ref(makeNews())
const isSaving = ref(false)

function makeNews(data = {}) {
  return {
    id: data.id,
    title: data.title,
    body: data.body,
    type: data.type,
    start: data.display_start,
    end: data.display_end
  }
}

function makePayload(data) {
  return {
    id: data.id,
    title: data.title,
    body: data.body,
    type: data.type,
    display_start: data.start,
    display_end: data.end
  }
}

async function save() {
  try {
    const newsId = news.value.id
    const payload = {
      news: makePayload(news.value)
    }

    isSaving.value = true

    const { body } = newsId
      ? await News.update(newsId, payload)
      : await News.create(payload)

    addToArray(list.value, body)
    TW.workbench.alert.create('News was successfully saved.', 'notice')
  } catch {
  } finally {
    isSaving.value = false
  }
}

function removeNews(item) {
  News.destroy(item.id)
    .then(() => {
      TW.workbench.alert.create('News was successfully destroyed.', 'notice')
      removeFromArray(list.value, item)
    })
    .catch(() => {})
}

function reset() {
  news.value = makeNews()
}

News.administration().then(({ body }) => {
  list.value = body.map(makeNews)
})
</script>

<style scoped>
.app-container {
  width: 1240px;
  margin: 1rem auto;
}
</style>
