<template>
  <div class="panel content gap-small">
    <h2>Object metadata</h2>
    <i>Added to all collection objects accordingly</i>
    <TotalComponent />
    <CatalogNumber />
    <RepositoryComponent />
    <PreparationType />
    <TaxonDetermination />
    <CollectingEvent />
    <TagComponent />
    <NoteComponent />
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
