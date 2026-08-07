<template>
  <div class="flex-wrap-column gap-medium">
    <div class="panel content">
      <h3>Object metadata</h3>
      <i>Added to all collection objects accordingly</i>
      <TotalComponent />
    </div>
    <CatalogNumber class="panel content" />
    <RepositoryComponent class="panel content" />
    <PreparationType class="panel content" />
    <TaxonDetermination class="panel content" />
    <CollectingEvent class="panel content" />
    <TagComponent class="panel content" />
    <NoteComponent class="panel content" />
  </div>
</template>

<script setup>
import CatalogNumber from './CatalogNumber'
import NoteComponent from './Note'
import TagComponent from './Tag'
import TaxonDetermination from './TaxonDetermination'
import CollectingEvent from './CollectingEvent'
import RepositoryComponent from './Repository'
import PreparationType from './PreparationType'
import TotalComponent from './Total.vue'
</script>

<style lang="scss" scoped>
:deep(.vue-autocomplete-input) {
  width: 100%;
}
</style>
