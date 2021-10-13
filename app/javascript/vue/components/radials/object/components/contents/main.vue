<template>
  <div class="content_annotator">
    <h3
      v-if="content.id"
      v-html="content.object_tag"/>
    <h3 v-else>New record</h3>
    <smart-selector
      class="full_width margin-small-bottom"
      ref="smartSelector"
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{'type[]' : 'Topic'}"
      get-url="/controlled_vocabulary_terms/"
      model="keywords"
      target="Otu"
      klass="Otu"
      :add-tabs="['all']"
      pin-section="Topic"
      buttons
      inline
      label="name"
      pin-type="BiologicalRelationship"
      @selected="setTopic"
    >
      <template #all>
        <a
          v-if="!allTopics.length"
          target="blank"
          href="/controlled_vocabulary_terms/new">
          Create a topic first.
        </a>
        <topic-item
          v-for="item in topicsAvailable"
          :key="item.id"
          :topic="item"
          :class="{ 'btn-data': content.topic_id !== item.id }"
          @select="setTopic"
        />
      </template>
    </smart-selector>
    <markdown-editor
      v-model="content.text"
      :configs="config"
    />
    <div class="margin-small-top margin-small-bottom">
      <button
        type="button"
        :disabled="!validate"
        class="button normal-input button-submit margin-small-right"
        @click="saveContent">
        Save
      </button>
      <button
        type="button"
        class="button normal-input button-default"
        @click="setContent(newContent())">
        New
      </button>
    </div>
    <table-list
      :header="['Text', 'Topic', '']"
      :attributes="['text', ['topic', 'name']]"
      :list="shortList"
      edit
      @delete="removeItem"
      @edit="setContent"
      class="list"/>
  </div>
</template>

<script>

import CRUD from '../../request/crud.js'
import annotatorExtend from '../../components/annotatorExtend.js'
import TopicItem from '../citations/topicItem.vue'
import TableList from 'components/table_list.vue'
import MarkdownEditor from 'components/markdown-editor.vue'
import SmartSelector from 'components/ui/SmartSelector.vue'
import { shorten } from 'helpers/strings.js'
import { ControlledVocabularyTerm, Content } from 'routes/endpoints'

export default {
  name: 'QuickContentForm',

  mixins: [CRUD, annotatorExtend],

  components: {
    SmartSelector,
    MarkdownEditor,
    TopicItem,
    TableList
  },

  data () {
    return {
      view: '',
      options: [],
      content: this.newContent(),
      config: {
        status: false,
        spellChecker: false
      },
      allTopics: []
    }
  },

  computed: {
    validate () {
      return this.content.text.length > 1 && this.content.topic_id
    },

    shortList () {
      return this.list.map(content => ({
        ...content,
        text: shorten(content.text, 150)
      }))
    },

    topicsAvailable () {
      return this.allTopics.filter(topic => !this.list.find(item => item.topic_id === topic.id))
    }
  },

  async created () {
    this.allTopics = (await ControlledVocabularyTerm.where({ type: ['Topic'] })).body
  },

  methods: {
    saveContent () {
      const content = this.content
      const saveRecord = this.content.id
        ? Content.update(content.id, { content })
        : Content.create({ content })

      saveRecord.then(response => {
        this.addRecord(response.body)
        TW.workbench.alert.create('Content was successfully saved.', 'notice')
        this.content = this.newContent()
      })
    },

    newContent () {
      return {
        text: '',
        topic_id: undefined,
        otu_id: this.metadata.object_id,
        type: this.objectType
      }
    },

    setTopic (topic) {
      this.content.topic_id = topic.id
    },

    addRecord (record) {
      const index = this.list.findIndex(item => item.id === record.id)

      if (index > -1) {
        this.list[index] = record
      } else {
        this.list.push(record)
      }
    },

    setContent (content) {
      this.content = content
    }
  }
}
</script>
