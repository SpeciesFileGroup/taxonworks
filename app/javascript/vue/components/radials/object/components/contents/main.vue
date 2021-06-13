<template>
  <div class="content_annotator">
    <smart-selector
      name="topic"
      :options="Object.keys(options)"
      v-model="view"/>
    <div class="separate-bottom">
      <template v-if="options['all'] && options['all'].length">
        <topic-item
          v-for="item in options[view]"
          v-if="!topicAlreadyCreated(item)"
          :class="{ 'button-data' : content.topic_id != item.id }"
          :key="item.id"
          :topic="item"
          @select="content.topic_id = $event.id"/>
      </template>
      <template v-else>
        <a
          target="blank"
          href="/controlled_vocabulary_terms/new">
          Create a topic first. 
        </a>
      </template>
    </div>
    <div class="separate-bottom">
      <textarea
        v-model="content.text"
        placeholder="Text..."/>
    </div>
    <div>
      <button
        type="button"
        :disabled="!validate"
        class="button normal-input button-submit"
        @click="createNew">
        Create
      </button>
    </div>
    <table-list
      :header="['Text', 'Topic', '']"
      :attributes="['text', ['topic', 'name']]"
      :list="shortList"
      @delete="removeItem"
      class="list">
      <template #options="slotProps">
        <a
          class="circle-button btn-edit"
          :href="`/tasks/content/editor/index?otu_id=${slotProps.item.otu_id}&topic_id=${slotProps.item.topic_id}`"></a>
      </template>
    </table-list>
  </div>
</template>

<script>

import CRUD from '../../request/crud.js'
import annotatorExtend from '../../components/annotatorExtend.js'
import SmartSelector from 'components/switch.vue'
import TopicItem from '../citations/topicItem.vue'
import TableList from 'components/table_list.vue'
import { shorten } from 'helpers/strings.js'

export default {
  mixins: [CRUD, annotatorExtend],
  components: {
    SmartSelector,
    TopicItem,
    TableList
  },
  computed: {
    validate () {
      return (this.content.text.length > 1 && this.content.topic_id != undefined)
    },
    shortList () {
      return this.list.map(content => {
        content.text = shorten(content.text, 150)
        return content
      })
    }
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
      promises.push(this.getList(`/controlled_vocabulary_terms.json?type[]=${type}`).then(response => {
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
