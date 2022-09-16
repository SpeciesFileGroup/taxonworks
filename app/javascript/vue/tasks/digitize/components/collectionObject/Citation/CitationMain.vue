<template>
  <div>
    <FormCitation
      v-model="citation"
      class="separate-top"
      :klass="COLLECTION_OBJECT"
      :submit-button="{
        label: 'Add',
        color: 'primary'
      }"
      @source="addLabel"
      @submit="addCitation"
    >
      <template #smart-selector-right>
        <v-lock
          class="margin-small-left"
          v-model="lock.coCitations"
        />
      </template>
    </FormCitation>
    <display-list
      :list="citations"
      label="citation_source_body"
      @delete-index="removeCitation"
    />
  </div>
</template>

<script>

import makeCitationObject from 'factory/Citation'
import DisplayList from 'components/displayList.vue'
import FormCitation from 'components/Form/FormCitation'
import VLock from 'components/ui/VLock'
import { GetterNames } from '../../../store/getters/getters'
import { MutationNames } from '../../../store/mutations/mutations'
import { ActionNames } from '../../../store/actions/actions'
import { COLLECTION_OBJECT } from 'constants/index.js'

export default {
  components: {
    FormCitation,
    DisplayList,
    VLock
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
    citation: makeCitationObject(COLLECTION_OBJECT)
  }),

  methods: {
    addCitation (citation) {
      this.citations.push(citation)
      this.citation = makeCitationObject(COLLECTION_OBJECT)
    },

    removeCitation (index) {
      this.$store.dispatch(ActionNames.RemoveCOCitation, index)
    },

    addLabel (source) {
      const author = [source.cached_author_string, source.year].filter(Boolean).join(', ')

      this.citation.citation_source_body = this.pages
        ? `${author}:${this.pages}`
        : author
    }
  }

}
</script>
