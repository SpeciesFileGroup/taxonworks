<template>
  <div>
    <citation-new
      v-model:lock="lock.coCitations"
      @onAdd="addCitation"/>
    <display-list
      :list="citations"
      label="citation_source_body"
      @deleteIndex="removeCitation"
    />
  </div>
</template>

<script>

import makeCitationObject from '../../../const/citation'
import CitationNew from './CitationNew.vue'
import DisplayList from 'components/displayList.vue'
import { GetterNames } from '../../../store/getters/getters'
import { MutationNames } from '../../../store/mutations/mutations'
import { ActionNames } from '../../../store/actions/actions'

export default {
  components: {
    DisplayList,
    CitationNew
  },

  computed: {
    citations: {
      get () {
        return this.$store.getters[GetterNames.GetCOCitations]
      },

      set () {
        this.$store.commit(MutationNames.SetCO)
      }
    },

    lock: {
      get () {
        return this.$store.getters[GetterNames.GetLocked]
      },

      set (value) {
        this.$store.commit(MutationNames.SetLocked, value)
      }
    }
  },

  data: () => ({
    citation: makeCitationObject()
  }),

  methods: {
    addCitation (citation) {
      this.citations.push(citation)
      this.citation = makeCitationObject()
    },

    removeCitation (index) {
      this.$store.dispatch(ActionNames.RemoveCOCitation, index)
    }
  }

}
</script>
