<template>
  <div class="panel content">
    <h3>Recent</h3>

    <RecentList
      v-if="otus.length"
      title="OTU"
      label="label"
      :list="otus"
      @select="(item) => loadOtu(item.otuId)"
    />
    <RecentList
      v-if="sources.length"
      title="Source"
      label="label"
      :list="sources"
      @select="(item) => loadSource(item.sourceId)"
    />
  </div>
</template>

<script setup>
import RecentList from './RecentList.vue'
import useStore from '../../../store/store.js'
import { Otu, Source } from '@/routes/endpoints'
import { computed } from 'vue'

const store = useStore()

const otus = computed(() =>
  store.sourceCitations.map((item) => ({
    globalId: item.citation_object.global_id,
    label: item.citation_object.object_tag,
    otuId: item.citation_object_id
  }))
)

const sources = computed(() =>
  store.otuCitations.map((item) => ({
    globalId: item.source.global_id,
    sourceId: item.source_id,
    label: item.source.object_tag
  }))
)

function loadOtu(otuId) {
  Otu.find(otuId)
    .then(({ body }) => {
      store.selected.otu = body
    })
    .catch(() => {})
}

function loadSource(sourceId) {
  Source.find(sourceId)
    .then(({ body }) => {
      store.selected.source = body
    })
    .catch(() => {})
}
</script>

<style scoped>
.panel {
  max-width: 600px;
  width: 600px;
}
</style>
