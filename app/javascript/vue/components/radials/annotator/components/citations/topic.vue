<template>
  <div>
    <h4>Topics</h4>
    <smart-selector
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{'type[]' : 'Topic'}"
      get-url="/controlled_vocabulary_terms/"
      model="topics"
      klass="Topic"
      pin-section="Topics"
      pin-type="Topic"
      target="Citation"
      :add-tabs="['all']"
      @selected="addTopic">
      <div
        v-if="slotProps.view === 'all'"
        class="flex-wrap-row"
        slot-scope="slotProps">
        <div 
          v-for="item in topicsAllList"
          :key="item.id"
          class="margin-medium-bottom cursor-pointer"
          v-html="item.object_tag"
          @click="addTopic(item)"/>
      </div>
    </smart-selector>
    <div class="field margin-medium-top">
      <input
        type="text"
        class="normal-input inline pages"
        v-model="pages"
        placeholder="Pages">
    </div>
    <div
      v-if="topicsSelected.length"
      class="margin-medium-top margin-medium-bottom">
      <h3>Selected topics</h3>
      <ul class="no_bullets">
        <li v-for="topic in topicsSelected">
          <span v-html="topic.object_tag"/>
        </li>
      </ul>
    </div>
    <button
      :disabled="!validateFields"
      type="button"
      class="button normal-input button-submit separate-bottom"
      @click="sendTopic">Create
    </button>
  </div>
</template>

<script>

  import CRUD from '../../request/crud'
  import Modal from 'components/modal.vue'
  import TopicItem from './topicItem.vue'
  import SmartSelector from 'components/smartSelector'

  export default {
    mixins: [CRUD],
    components: {
      Modal,
      TopicItem,
      SmartSelector
    },
    props: {
      globalId: {
        type: String,
        required: true,
      },
      citation: {
        type: Object,
        required: true
      },
      objectType: {
        type: String,
        required: true
      }
    },
    computed: {
      validateFields() {
        return this.topicsSelected.length
      }
    },
    data() {
      return {
        pages: undefined,
        topicsSelected: [],
        topicsAllList: undefined
      }
    },
    mounted () {
      this.getList('/controlled_vocabulary_terms.json?type[]=Topic').then(response => {
        this.topicsAllList = response.body
      })
    },
    methods: {
      topicAlreadyCreated(topic) {
        return this.citation.citation_topics.find(item => { return topic.id == item.topic_id })
      },
      sendTopic() {
        this.$emit('create', {
          id: this.citation.id,
          citation_topics_attributes: this.topicsSelected.map(topic => { 
            return {
              topic_id: topic.id,
              pages: this.pages
            }
          })
        })
        this.topicsSelected = []
      },
      setViewWithTopics(listView) {
        let keys = Object.keys(listView);
        let that = this;

        keys.some(function(key) {
          if(listView[key].find(item => { return !that.topicAlreadyCreated(item) })) {
            that.view = key
            return true
          }
        })
      },
      addTopic(topic) {
        if (this.topicsSelected.find(item => item.id === topic.id) || this.topicAlreadyCreated(topic)) return
        this.topicsSelected.push(topic)
      }
    }
  }
</script>