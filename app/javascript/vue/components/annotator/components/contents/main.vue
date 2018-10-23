<template>
  <div class="content_annotator">
    <smart-selector
      name="topic"
      :options="Object.keys(options)"
      v-model="view"/>
    <div class="separate-bottom">
      <topic-item
        v-for="item in options[view]"
        :class="{ 'button-data' : content.topic_id != item.id }"
        :key="item.id"
        :topic="item"
        @select="content.topic_id = $event.id"/>
    </div>
    <div class="separate-bottom">
      <textarea
        v-model="content.text"
        placeholder="Text..."/>
    </div>
    <div>
      <button
        type="button"
        class="button normal-input button-submit"
        @click="createNew">
        Create
      </button>
    </div>
    <table-list
      :header="['Text', 'Topic', '']"
      :attributes="['text', ['topic', 'name']]"
      :list="list"
      @delete="removeItem"
      class="list"/>
  </div>
  
</template>

<script>

import CRUD from '../../request/crud.js'
import annotatorExtend from '../../components/annotatorExtend.js'
import SmartSelector from 'components/switch.vue'
import TopicItem from '../citations/topicItem.vue'
import TableList from 'components/table_list.vue'

export default {
  mixins: [CRUD, annotatorExtend],
  components: {
    SmartSelector,
    TopicItem,
    TableList
  },
  data() {
    return {
      view: '',
      options: [],
      content: this.newContent()
    }
  },
  mounted() {
    this.loadTabList('Topic')
  },
  methods: {
    createNew() {
      this.create('/contents', { content: this.content }).then(response => {
        this.list.push(response.body)
        this.content = this.newContent()
      })
    },
    newContent() {
      return {
        text: '',
        topic_id: undefined,
        otu_id: this.metadata.object_id,
        type: this.objectType
      }
    },
    topicAlreadyCreated(topic) {
      return this.list.find(item => { return topic.id == item.topic_id })
    },
    setViewWithTopics(listView) {
      let keys = Object.keys(listView)
      let that = this

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
      promises.push(this.getList(`/controlled_vocabulary_terms.json?of_type[]=${type}`).then(response => {
        allList = response.body
      }))

      Promise.all(promises).then(() => {
        tabList['all'] = allList
        Object.keys(tabList).forEach(key => (!tabList[key].length) && delete tabList[key])
        that.options = tabList
        that.setViewWithTopics(tabList);
      })
    }
  }
}
</script>
<style lang="scss">
.radial-annotator {
  .content_annotator {
		button {
			min-width: 100px;
		}
		textarea {
			padding-top: 14px;
			padding-bottom: 14px;
			width: 100%;
			height: 100px;
		}
  }
}
</style>
