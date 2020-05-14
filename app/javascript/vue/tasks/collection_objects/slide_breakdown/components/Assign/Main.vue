<template>
  <div class="panel content">
    <h2>Object metadata</h2>
    <span><i>Added to all collection objects accordingly</i></span>
    <metadata-component class="margin-medium-top"/>
    <catalog-number class="margin-medium-bottom"/>
    <repository-component class="margin-medium-bottom"/>
    <preparation-type class="margin-medium-bottom"/>
    <taxon-determination class="margin-medium-bottom"/>
    <collecting-event class="margin-medium-bottom"/>
    <tag-component class="margin-medium-bottom"/>
    <note-component class="margin-medium-bottom"/>
    <container-component class="margin-medium-bottom"/>
  </div>
</template>

<script>

import CatalogNumber from './CatalogNumber'
import ContainerComponent from './Container'
import NoteComponent from './Note'
import TagComponent from './Tag'
import TaxonDetermination from './TaxonDetermination'
import CollectingEvent from './CollectingEvent'
import RepositoryComponent from './Repository'
import PreparationType from './PreparationType'
import MetadataComponent from './Metadata'

export default {
  components: {
    CatalogNumber,
    ContainerComponent,
    NoteComponent,
    TagComponent,
    TaxonDetermination,
    CollectingEvent,
    RepositoryComponent,
    PreparationType,
    MetadataComponent
  }
}
</script>
<style lang="scss" scoped>
  /deep/ .vue-autocomplete-input {
    width: 100%;
  }
</style>