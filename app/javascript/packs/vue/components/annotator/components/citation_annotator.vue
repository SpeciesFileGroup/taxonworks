<template>
  <div class="citation_annotator">
    <div v-if="!citation.hasOwnProperty('id')">
      <div class="separate-bottom inline">
        <autocomplete
          url="/sources/autocomplete"
          label="label"
          min="2"
          :send-label="autocompleteLabel"
          @getItem="citation.source_id = $event.id"
          placeholder="Select a source"
          param="term"/>
        <input
          type="text"
          class="normal-input inline pages"
          v-model="citation.pages"
          placeholder="Pages">
      </div>
      <div class="flex-separate separate-bottom">
        <label class="inline middle">
          <input
            v-model="citation.is_original"
            type="checkbox">
          Is original
        </label>
        <default-element
          class="separate-left"
          label="source"
          type="Source"
          @getLabel="autocompleteLabel = $event"
          @getId="citation.source_id = $event"
          section="Sources"
        />
      </div>
      <div class="separate-bottom inline">
        <autocomplete
          url="/topics/autocomplete"
          label="label"
          min="2"
          @getItem="topic.topic_id = $event.id"
          placeholder="Topic"
          param="term"/>
        <input
          type="text"
          class="normal-input inline pages"
          v-model="topic.pages"
          placeholder="Pages">
      </div>
      <div class="separate-bottom">
        <button
          class="button button-submit normal-input"
          :disabled="!validateFields"
          @click="createNew()"
          type="button">Create
        </button>
      </div>
      <display-list
        :edit="true"
        @edit="citation = loadCitation($event)"
        label="object_tag"
        :list="list"
        @delete="removeItem"
        class="list"/>
    </div>
    <div v-else>
      <span
        v-if="citation.hasOwnProperty('id')"
        v-html="citation.object_tag"/>
      <div class="horizontal-left-content separate-bottom separate-top">
        <label class="inline middle">
          <input
            v-model="citation.is_original"
            type="checkbox">
          Is original
        </label>
      </div>
      <div class="separate-bottom inline">
        <autocomplete
          url="/topics/autocomplete"
          label="label"
          min="2"
          @getItem="topic.topic_id = $event.id"
          placeholder="Topic"
          param="term"/>
        <input
          type="text"
          class="normal-input inline pages"
          v-model="topic.pages"
          placeholder="Pages">
      </div>
      <div class="separate-bottom">
        <button
          class="button button-submit normal-input"
          :disabled="!validateFields"
          @click="updateCitation()"
          type="button">Update
        </button>
        <button
          class="button button-default normal-input"
          :disabled="!validateFields"
          @click="citation = newCitation()"
          type="button">New
        </button>
      </div>
      <display-list
        :label="['topic', 'object_tag']"
        :list="citation.citation_topics"
        @delete="deleteTopic"
        class="list"/>
    </div>
  </div>
</template>
<script>

  import CRUD from '../request/crud.js'
  import annotatorExtend from '../components/annotatorExtend.js'
  import autocomplete from '../../autocomplete.vue'
  import displayList from './displayList.vue'
  import defaultElement from '../../getDefaultPin.vue'

  export default {
    mixins: [CRUD, annotatorExtend],
    components: {
      defaultElement,
      autocomplete,
      displayList
    },
    computed: {
      validateFields() {
        return this.citation.source_id
      }
    },
    data: function () {
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
      updateCitation() {
        if (this.topic.topic_id) {
          this.citation.citation_topics_attributes.push(this.topic)
        }

        this.update(`/citations/${this.citation.id}`, {citation: this.citation}).then(response => {
          this.citation = this.loadCitation(response.body)
          this.list[this.list.findIndex(element => element.id == this.citation.id)] = response.body
          this.topic = this.newTopic()
          TW.workbench.alert.create('Citation was successfully updated.', 'notice')
        })
      },
      createNew() {
        if (this.topic.topic_id) {
          this.citation.citation_topics_attributes.push(this.topic)
        }
        this.create('/citations', {citation: this.citation}).then(response => {
          this.list.push(response.body)
          this.citation = this.newCitation()
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
        margin-left: 8px;
        width: 86px;
      }
      .vue-autocomplete-input, .vue-autocomplete {
        width: 400px;
      }
    }
  }
</style>
