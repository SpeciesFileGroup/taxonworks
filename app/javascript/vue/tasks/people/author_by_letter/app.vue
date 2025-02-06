<template>
  <div>
    <spinner
      v-if="isLoading"
      full-screen
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px' }"
    />
    <h1>Author by first letter</h1>
    <AlphabetButtons
      class="margin-medium-bottom"
      v-model="key"
      @update:model-value="getAuthors"
    />
    <VPagination
      :pagination="pagination"
      @next-page="getAuthors"
    />
    <div class="horizontal-left-content align-start">
      <div class="separate-right">
        <AuthorList
          :list="authorsList"
          @selected="getSources"
        />
      </div>
      <div class="separate-left">
        <SourceList
          v-show="sourcesList.length"
          :list="sourcesList"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import AlphabetButtons from './components/AlphabetButtons.vue'
import AuthorList from './components/Author/AuthorList.vue'
import SourceList from './components/Source/SourceList.vue'
import Spinner from '@/components/ui/VSpinner.vue'
import VPagination from '@/components/pagination.vue'
import GetPagination from '@/helpers/getPagination.js'
import { ROLE_SOURCE_AUTHOR } from '@/constants'
import { Source, People } from '@/routes/endpoints'
import { ref, onBeforeMount } from 'vue'
import { URLParamsToJSON } from '@/helpers'

const authorsList = ref([])
const sourcesList = ref([])
const isLoading = ref(false)
const key = ref()
const pagination = ref({})

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(window.location.search)
  let letterParam = urlParams.letter

  if (letterParam) {
    letterParam = letterParam.toUpperCase()
  }

  if (/([A-Z])$/.test(letterParam) && letterParam.length == 1) {
    key.value = letterParam
    getAuthors()
  }
})

function getAuthors(params = {}) {
  const payload = {
    last_name_starts_with: key.value,
    roles: [ROLE_SOURCE_AUTHOR],
    extend: ['roles'],
    ...params
  }

  isLoading.value = true
  People.where(payload)
    .then((response) => {
      authorsList.value = response.body
      pagination.value = GetPagination(response)
    })
    .finally(() => (isLoading.value = false))
}

function getSources(authorId) {
  isLoading.value = true
  Source.where({ author_id: [authorId] }).then((response) => {
    sourcesList.value = response.body
    isLoading.value = false
  })
}
</script>
