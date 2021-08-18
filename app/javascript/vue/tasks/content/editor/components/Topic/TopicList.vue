<template>
  <div>
    <smart-selector
      :autocomplete-params="{'type[]' : 'Topic'}"
      model="topics"
      target="Content"
      klass="Content"
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      get-url="/controlled_vocabulary_terms/"
      :custom-list="{ all: topics }"
      @selected="selected"
    />
    <topic-new
      class="margin-medium-top"
      @onCreate="selected"/>
  </div>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector.vue'
import TopicNew from './TopicNew.vue'
import { Topic } from 'routes/endpoints'

export default {
  components: {
    SmartSelector,
    TopicNew
  },

  emits: ['onSelect'],

  data () {
    return {
      topics: []
    }
  },

  created () {
    Topic.all().then(({ body }) => {
      this.topics = body
    })
  },

  methods: {
    selected (topic) {
      this.$emit('onSelect', topic)
    }
  }
}
</script>
