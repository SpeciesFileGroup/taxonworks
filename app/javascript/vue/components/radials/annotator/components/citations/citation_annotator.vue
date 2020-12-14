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
      <citation-topic
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
          <tr v-for="(item, index) in citation.citation_topics">
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
import CitationTopic from './topic.vue'
import TopicPages from './pagesUpdate'
import HandleCitations from './handleOriginalModal'

export default {
  mixins: [CRUD, annotatorExtend],
  components: {
    CitationNew,
    CitationEdit,
    CitationTopic,
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
      currentCitation: undefined
    }
  },
  methods: {
    setCitation(citation) {
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
      const object = {
        id: this.citation.id,
        citation_topics_attributes: [{
          id: topic.id,
          _destroy: true
        }]
      }
      this.update(`/citations/${object.id}`, { citation: object }).then(response => {
        this.citation.citation_topics.splice(
          this.citation.citation_topics.findIndex(element => element.id == topic.id), 1)
      })
    },
    updateCitation (editCitation) {
      this.update(`/citations/${editCitation.id}`, { citation: editCitation }).then(response => {
        this.citation = response.body
        this.list[this.list.findIndex(element => element.id == editCitation.id)] = response.body
        TW.workbench.alert.create('Citation was successfully updated.', 'notice')
      })
    },
    async createNew (newCitation) {
      if (newCitation.is_original) {
        const loadCitations = await this.getList('/citations.json', {
          params: {
            citation_object_type: this.objectType,
            citation_object_id: this.metadata.object_id,
            is_original: true
          }
        })
        this.existingOriginal = loadCitations.body
        this.currentCitation = newCitation
      }
      if (this.existingOriginal.length) {
        this.showModal = true
      } else {
        this.create('/citations', { citation: newCitation }).then(response => {
          this.list.push(response.body)
          this.citation = response.body
          TW.workbench.alert.create('Citation was successfully created.', 'notice')
        })
      }
    },
    updateTopic (topic) {
      this.update(`/citation_topics/${topic.id}.json`, { citation_topic: topic }).then(response => {
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
      button {
        min-width: 100px;
      }
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
