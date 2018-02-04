<template>
  <div class="citation_annotator">
    <div v-if="!citation.hasOwnProperty('id')">
      <citation-new
        :global-id="globalId"
        @create="createNew"/>
      <display-list
        :edit="true"
        :pdf="true"
        label="object_tag"
        :list="list"
        @edit="citation = loadCitation($event)"
        @delete="removeItem"
        class="list"/>
    </div>
    <div v-else>
      <citation-edit
        :global-id="globalId"
        :citation="citation"
        @new="citation = newCitation()"/>
      <citation-topic
        :object-type="objectType"
        :global-id="globalId"
        :citation="citation"
        @create="updateCitation"/>
      <display-list
        :label="['topic', 'object_tag']"
        :list="citation.citation_topics"
        @delete="deleteTopic"
        class="list"/>
    </div>
  </div>
</template>
<script>

  import CRUD from '../../request/crud.js'
  import annotatorExtend from '../annotatorExtend.js'
  import autocomplete from '../../../autocomplete.vue'
  import displayList from '../displayList.vue'
  import defaultElement from '../../../getDefaultPin.vue'
  import CitationNew from './new.vue'
  import CitationEdit from './edit.vue'
  import CitationTopic from './topic.vue'

  export default {
    mixins: [CRUD, annotatorExtend],
    components: {
      CitationNew,
      CitationEdit,
      CitationTopic,
      defaultElement,
      autocomplete,
      displayList
    },
    computed: {
      validateFields() {
        return this.citation.source_id
      }
    },
    data() {
      return {
        list: [],
        citation: this.newCitation(),
        topic: this.newTopic(),
        autocompleteLabel: undefined
      }
    },
    methods: {
      newCitation() {
        return {
          annotated_global_entity: decodeURIComponent(this.globalId),
          source_id: undefined,
          is_original: false,
          pages: undefined,
          citation_topics_attributes: []
        }
      },
      newTopic() {
        return {
          topic_id: undefined,
          pages: undefined
        }
      },
      deleteTopic(topic) {
        let object = {
          id: this.citation.id,
          citation_topics_attributes: [{
            id: topic.id,
            _destroy: true
          }]
        }
        this.update(`/citations/${object.id}`, {citation: object}).then(response => {
          this.citation.citation_topics.splice(
            this.citation.citation_topics.findIndex(element => element.id == topic.id), 1)
        })
      },
      loadCitation(citation) {
        return {
          id: citation.id,
          source_id: citation.source.id,
          is_original: citation.is_original,
          citation_topics: citation.citation_topics,
          object_tag: citation.object_tag,

          citation_topics_attributes: []
        }
      },
      updateCitation(editCitation) {
        this.update(`/citations/${editCitation.id}`, { citation: editCitation }).then(response => {
          this.citation = this.loadCitation(response.body)
          this.list[this.list.findIndex(element => element.id == editCitation.id)] = response.body
          TW.workbench.alert.create('Citation was successfully updated.', 'notice')
        })
      },
      createNew(newCitation) {
        this.create('/citations', {citation: newCitation}).then(response => {
          this.list.push(response.body)
          this.citation = response.body
          TW.workbench.alert.create('Citation was successfully created.', 'notice')
        })
      }
    }
  }
</script>
<style type="text/css" lang="scss">
  .radial-annotator {
    .citation_annotator {
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
        //margin-left: 8px;
        width: 86px;
      }
      .vue-autocomplete-input, .vue-autocomplete {
        width: 400px;
      }
    }
  }
</style>
