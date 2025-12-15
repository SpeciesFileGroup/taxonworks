<template>
  <div class="matches-panel">
    <spinner-component
      v-if="isSearching"
      legend="Searching..."
    />
    <div class="panel padding-medium-left padding-medium-right">
      <DisplayList
        v-if="list.length"
        :list="list"
        label="object_tag"
        :remove="false"
        :edit="true"
        @edit="loadSource"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { Source } from '@/routes/endpoints'
import { useSettingStore, useSourceStore } from '../store'
import DisplayList from '@/components/displayList'
import SpinnerComponent from '@/components/ui/VSpinner'

const store = useSourceStore()
const settings = useSettingStore()

const DELAY = 1000
let timer

const list = ref([])

const isSearching = ref(false)

watch(
  () => settings.saving,
  (newVal) => {
    if (!newVal) {
      getRecent()
    }
  }
)

watch(
  () => store.source.title,
  (newVal) => {
    clearTimeout(timer)

    if (!newVal) {
      isSearching.value = true

      timer = setTimeout(() => {
        getRecent()
      }, DELAY)

      return
    }

    isSearching.value = false
    list.value = []
  }
)

function getRecent() {
  isSearching.value = true
  Source.where({ query_term: store.source.title, per: 5 })
    .then(({ body }) => {
      list.value = store.source.id
        ? body.filter((item) => item.id !== store.source.id)
        : body
    })
    .finally(() => {
      isSearching.value = false
    })
}

function loadSource(source) {
  store.loadSource(source.id)
}
</script>
