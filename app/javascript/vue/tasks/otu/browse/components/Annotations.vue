<template>
  <div class="panel content">
    <h3>Annotations</h3>
    <list-component
      v-if="citations.length"
      title="Citations"
      :list="citations"/>
    <list-component
      v-if="dataAttributes.length"
      title="Data attributes"
      :list="dataAttributes"/>
    <list-component
      v-if="identifiers.length"
      title="Identifiers"
      :list="identifiers"/>
    <list-component
      v-if="notes.length"
      title="Notes"
      :list="notes"/>
    <list-component
      v-if="tags.length"
      title="Tags"
      :list="tags"/>            
  </div>
</template>

<script>

import ListComponent from './shared/list'
import { GetIdentifiers, GetNotes, GetTags, GetCitations, GetDataAttributes } from '../request/resources.js'

export default {
  components: {
    ListComponent
  },
  props: {
    otu: {
      type: Object
    }
  },
  data() {
    return {
      identifiers: [],
      notes: [],
      citations: [],
      dataAttributes: [],
      tags: []
    }
  },
  watch: {
    otu(newVal) {
      if(newVal) {
        GetIdentifiers(this.otu.id).then(response => {
          this.identifiers = response.body
        })
        GetTags(this.otu.id).then(response => {
          this.tags = response.body
        })
        GetNotes(this.otu.id).then(response => {
          this.notes = response.body
        })
        GetCitations(this.otu.id).then(response => {
          this.citations = response.body
        })
        GetDataAttributes(this.otu.id).then(response => {
          this.dataAttributes = response.body
        })
      }
    }
  }
}
</script>
