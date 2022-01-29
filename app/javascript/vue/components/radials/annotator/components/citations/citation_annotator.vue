<template>
  <div class="citation_annotator">
    <div v-if="!citation.hasOwnProperty('id')">
      <citation-new
        :global-id="globalId"
        :object-type="objectType"
        @create="createNew"
      />
      <table-list
        :list="list"
        @edit="citation = $event"
        @delete="removeItem"
      />
    </div>
    <div v-else>
      <citation-edit
        :global-id="globalId"
        :citation="citation"
        @update="updateCitation"
        @new="citation = newCitation()"
      />
      <citation-topic-component
        v-if="!disabledFor.includes(objectType)"
        :object-type="objectType"
        :global-id="globalId"
        :citation="citation"
        @create="updateCitation"
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
            :key="item.id">
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
      :citation="currentCitation"
      :original-citation="existingOriginal[0]"
      @create="setCitation"
      @close="resetCitations"
    />
  </div>
</template>
<script>

import CRUD from '../../request/crud.js'
import annotatorExtend from '../annotatorExtend.js'
import TableList from './table.vue'
import CitationNew from './new.vue'
import CitationEdit from './edit.vue'
import CitationTopicComponent from './topic.vue'
import TopicPages from './pagesUpdate'
import HandleCitations from './handleOriginalModal'
import { Citation, CitationTopic } from 'routes/endpoints'

const EXTEND_PARAMS = ['source', 'citation_topics']

export default {
  mixins: [CRUD, annotatorExtend],
  components: {
    CitationNew,
    CitationEdit,
    CitationTopicComponent,
    TableList,
    TopicPages,
    HandleCitations
  },
  computed: {
    validateFields () {
      return this.citation.source_id
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
        annotated_global_entity: decodeURIComponent(this.globalId),
        source_id: undefined,
        is_original: false,
        pages: undefined,
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
    updateCitation (citation) {
      Citation.update(citation.id, { citation, extend: EXTEND_PARAMS }).then(response => {
        this.citation = response.body
        this.list[this.list.findIndex(element => element.id === citation.id)] = response.body
        TW.workbench.alert.create('Citation was successfully updated.', 'notice')
      })
    },
    async createNew (citation) {
      if (citation.is_original) {
        const loadCitations = await Citation.where({
          citation_object_type: this.objectType,
          citation_object_id: this.metadata.object_id,
          is_original: true,
          extend: EXTEND_PARAMS
        })
        this.existingOriginal = loadCitations.body
        this.currentCitation = citation
      }
      if (this.existingOriginal.length) {
        this.showModal = true
      } else {
        Citation.create({ citation, extend: EXTEND_PARAMS }).then(response => {
          this.list.push(response.body)
          this.citation = response.body
          TW.workbench.alert.create('Citation was successfully created.', 'notice')
        })
      }
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
