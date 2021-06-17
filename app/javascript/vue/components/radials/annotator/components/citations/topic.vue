<template>
  <div>
    <h4>Topics</h4>
    <smart-selector
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{'type[]' : 'Topic'}"
      get-url="/controlled_vocabulary_terms/"
      model="topics"
      :klass="objectType"
      pin-section="Topics"
      pin-type="Topic"
      target="Citation"
      :add-tabs="['all']"
      @selected="sendTopic">
      <template #all>
        <div class="flex-wrap-row">
          <div
            v-for="item in topicsAllList"
            :key="item.id"
            class="margin-medium-bottom cursor-pointer"
            v-html="item.object_tag"
            @click="sendTopic(item)"/>
        </div>
      </template>
    </smart-selector>
    <div
      v-if="topicsSelected.length"
      class="margin-medium-top margin-medium-bottom">
      <h3>Selected topics</h3>
      <ul class="no_bullets">
        <li
          v-for="topic in topicsSelected"
          :key="topic.id">
          <span v-html="topic.object_tag"/>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>

import CRUD from '../../request/crud'
import SmartSelector from 'components/ui/SmartSelector'

export default {
  mixins: [CRUD],
  components: {
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
    validateFields () {
      return this.topicsSelected.length
    }
  },
  data() {
    return {
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
    sendTopic (topic) {
      this.$emit('create', {
        id: this.citation.id,
        citation_topics_attributes: [{ topic_id: topic.id }]
      })
    }
  }
}
</script>