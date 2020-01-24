<template>
  <div class="panel content">
    <h2>Assign</h2>
    <metadata-component class="margin-medium-bottom"/>
    <catalog-number class="margin-medium-bottom"/>
    <taxon-determination class="margin-medium-bottom"/>
    <container-component class="margin-medium-bottom"/>
    <collecting-event class="margin-medium-bottom"/>
    <tag-component class="margin-medium-bottom"/>
    <note-component class="margin-medium-bottom"/>
  </div>
</template>

<script>

import MetadataComponent from './Metadata'
import CatalogNumber from './CatalogNumber'
import ContainerComponent from './Container'
import NoteComponent from './Note'
import TagComponent from './Tag'
import TaxonDetermination from './TaxonDetermination'
import CollectingEvent from './CollectingEvent'

export default {
  components: {
    MetadataComponent,
    CatalogNumber,
    ContainerComponent,
    NoteComponent,
    TagComponent,
    TaxonDetermination,
    CollectingEvent
  }
}
</script>
<style lang="scss" scoped>
  /deep/ .vue-autocomplete-input {
    width: 100%;
  }
</style>