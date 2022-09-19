<template>
  <div class="citation_annotator">
    <FormCitation
      v-model="citation"
      :submit-button="{
        label: 'Save',
        color: 'create'
      }"
      @submit="saveCitation(citation)"
    >
      <template #footer>
        <VBtn
          class="margin-small-left"
          color="primary"
          medium
          @click="citation = newCitation()"
        >
          New
        </VBtn>
      </template>
    </FormCitation>
    <div v-if="!citation.id">
      <table-list
        :list="list"
        @edit="citation = $event"
        @delete="removeItem"
      />
    </div>
    <div v-else>
      <citation-topic-component
        v-if="!disabledFor.includes(objectType)"
        :object-type="objectType"
        :global-id="globalId"
        :citation="citation"
        @create="saveCitation"
      />
      <table class="full_width">
        <thead>
          <tr>
            <th>Topic</th>
            <th>Pages</th>
            <th />
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="(item, index) in citation.citation_topics"
            :key="item.id"
          >
            <td v-html="item.topic.object_tag" />
            <td>
              <topic-pages
                v-model="citation.citation_topics[index]"
                :citation-id="citation.id"
                @update="updateCitation"
              />
            </td>
            <td class="horizontal-right-content">
              <span
                class="button circle-button btn-delete"
                @click="deleteTopic(item)"
              />
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <handle-citations
      v-if="showModal"
      :citation="citation"
      :original-citation="originalCitation"
      @create="setCitation"
      @close="resetCitations"
    />
  </div>
</template>
<script>

import CRUD from '../../request/crud.js'
import annotatorExtend from '../annotatorExtend.js'
import TableList from './table.vue'
import FormCitation from 'components/Form/FormCitation.vue'
import CitationTopicComponent from './topic.vue'
import TopicPages from './pagesUpdate'
import HandleCitations from './handleOriginalModal'
import VBtn from 'components/ui/VBtn/index.vue'
import makeCitation from 'factory/Citation'
import { Citation, CitationTopic } from 'routes/endpoints'
import { addToArray } from 'helpers/arrays'

const EXTEND_PARAMS = ['source', 'citation_topics']

export default {
  mixins: [CRUD, annotatorExtend],
  components: {
    CitationTopicComponent,
    TableList,
    TopicPages,
    HandleCitations,
    FormCitation,
    VBtn
  },
  computed: {
    validateFields () {
      return this.citation.source_id
    },

    originalCitation () {
      return this.list.find(c => c.is_original)
    }
  },
  data () {
    return {
      list: [],
      citation: this.newCitation(),
      topic: this.newTopic(),
      autocompleteLabel: undefined,
      disabledFor: ['Content'],
      showModal: false,
      existingOriginal: [],
      currentCitation: undefined,
      loadOnMounted: false
    }
  },

  created () {
    Citation.where({
      citation_object_id: this.metadata.object_id,
      citation_object_type: this.metadata.object_type,
      extend: EXTEND_PARAMS
    }).then(({ body }) => {
      this.list = body
    })
  },

  methods: {
    setCitation (citation) {
      this.resetCitations()
      this.citation = citation
      this.loadObjectsList()
    },

    resetCitations () {
      this.showModal = false
      this.currentCitation = undefined
      this.existingOriginal = []
    },

    newCitation () {
      return {
        ...makeCitation(),
        citation_object_id: this.metadata.object_id,
        citation_object_type: this.metadata.object_type,
        citation_topics_attributes: []
      }
    },

    newTopic () {
      return {
        topic_id: undefined,
        pages: undefined
      }
    },

    deleteTopic (topic) {
      const citation = {
        id: this.citation.id,
        citation_topics_attributes: [{
          id: topic.id,
          _destroy: true
        }]
      }
      Citation.update(citation.id, { citation, extend: EXTEND_PARAMS }).then(_ => {
        this.citation.citation_topics.splice(
          this.citation.citation_topics.findIndex(element => element.id === topic.id), 1)
      })
    },

    saveCitation (citation) {
      const payload = {
        ...citation,
        citation_object_type: this.objectType,
        citation_object_id: this.metadata.object_id,
        extend: EXTEND_PARAMS
      }

      if (
        payload.is_original &&
        this.originalCitation &&
        this.originalCitation.id !== payload.id
      ) {
        this.showModal = true

        return
      }

      const request = payload.id
        ? Citation.update(payload.id, { citation: payload })
        : Citation.create({ citation: payload })

      request.then(({ body }) => {
        addToArray(this.list, body)
        this.citation = body
        TW.workbench.alert.create('Citation was successfully saved.', 'notice')
      })
    },

    updateTopic (citation_topic) {
      CitationTopic.update(citation_topic.id, { citation_topic }).then(_ => {
        TW.workbench.alert.create('Topic was successfully updated.', 'notice')
      })
    }
  }
}
</script>
<style lang="scss">
  .radial-annotator {
    .citation_annotator {
      overflow-y: scroll;

      textarea {
        padding-top: 14px;
        padding-bottom: 14px;
        width: 100%;
        height: 100px;
      }
      .pages {
        width: 86px;
      }
      .vue-autocomplete-input, .vue-autocomplete {
        width: 400px;
      }
    }
  }
</style>
