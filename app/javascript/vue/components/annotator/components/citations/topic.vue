<template>
  <div>
    <h4>Topics</h4>
    <div
      class="switch-radio separate-bottom"
      v-if="preferences">
      <template
      v-for="(item, index) in tabOptions">
        <template v-if="preferences[item].length && preferences[item].find(topicItem => { return !topicAlreadyCreated(topicItem) })">
          <input
            v-model="view"
            :value="item"
            :id="`switch-picker-${index}`"
            name="switch-picker-options"
            type="radio"
            class="normal-input button-active"
          >
          <label
            :for="`switch-picker-${index}`"
            class="capitalize">{{ item }}
          </label>
        </template>
      </template>
    </div>

    <template v-if="preferences">
      <div class="field">
        <template v-for="option in tabOptions">
          <template
            v-if="view === option"
            v-for="item in preferences[view]">
            <topic-item
              v-if="!topicAlreadyCreated(item)"
              :key="item.id"
              :topic="item"
              :class="{ 'button-default': (topic && topic.topic_id === item.id) }"
              @select="topic.topic_id = $event.id"/>
          </template>
        </template>
      </div>
      <div class="field">
        <input
          type="text"
          class="normal-input inline pages"
          v-model="topic.pages"
          placeholder="Pages">
      </div>
      <button
        :disabled="!validateFields"
        type="button"
        class="button normal-input button-submit separate-bottom"
        @click="sendTopic">Create
      </button>
    </template>
  </div>
</template>

<script>

  import CRUD from '../../request/crud'
  import Autocomplete from '../../../autocomplete.vue'
  import Modal from '../../../modal.vue'
  import TopicItem from './topicItem.vue'

  export default {
    mixins: [CRUD],
    components: {
      Modal,
      Autocomplete,
      TopicItem
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
        return this.topic.topic_id
      }
    },
    data() {
      return {
        preferences: undefined,
        view: 'quick',
        tabOptions: ['quick', 'recent', 'pinboard', 'all'],
        topic: this.newTopic()
      }
    },
    mounted() {
      this.loadTabList('Topic');
    },
    methods: {
      newTopic() {
        return {
          topic_id: undefined,
          pages: undefined
        }
      },
      topicAlreadyCreated(topic) {
        return this.citation.citation_topics.find(item => { return topic.id == item.topic_id })
      },
      sendTopic() {
        this.$emit('create', {
          id: this.citation.id,
          citation_topics_attributes: [{
            topic_id: this.topic.topic_id,
            pages: this.topic.pages
          }]
        })
        this.topic = this.newTopic();
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
      loadTabList (type) {
        let tabList
        let allList
        let promises = []
        let that = this

        promises.push(this.getList(`/topics/select_options?klass=${this.objectType}&target=Citation`).then(response => {
          tabList = response.body
        }))
        promises.push(this.getList(`/controlled_vocabulary_terms.json?type[]=${type}`).then(response => {
          allList = response.body
        }))

        Promise.all(promises).then(() => {
          tabList['all'] = allList
          that.preferences = tabList
          that.setViewWithTopics(tabList);
        })
      }
    }
  }
</script>