<template>
  <div>
    <h2>Topics</h2>
    <fieldset>
      <legend>Topics</legend>
      <smart-selector
        :autocomplete-params="{'type[]' : 'Topic'}"
        model="topics"
        target="Citation"
        klass="Topic"
        autocomplete-url="/controlled_vocabulary_terms/autocomplete"
        get-url="/controlled_vocabulary_terms/"
        @selected="addTopic"/>
    </fieldset>
    <display-list
      :list="topics"
      label="object_tag"
      @deleteIndex="removeTopic"/>
  </div>
</template>

<script>

import SmartSelector from 'components/smartSelector'
import DisplayList from 'components/displayList'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { GetKeyword } from '../../request/resources'

export default {
  components: {
    SmartSelector,
    DisplayList
  },
  props: {
    value: {
      type: Array,
      default: () => { return [] }
    }
  },
  computed: {
    params: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  data () {
    return {
      topics: []
    }
  },
  watch: {
    value (newVal, oldVal) {
      if (!newVal.length && oldVal.length) {
        this.topics = []
      }
    },
    topics: {
      handler (newVal) {
        this.params = this.topics.map(topic => { return topic.id })
      },
      deep: true
    }
  },
  mounted () {
    const urlParams = URLParamsToJSON(location.href)
    if (urlParams.topic_ids) {
      urlParams.topic_ids.forEach(id => {
        GetKeyword(id).then(response => {
          this.addTopic(response.body)
        })
      })
    }
  },
  methods: {
    addTopic (topic) {
      if (!this.params.includes(topic.id)) {
        this.topics.push(topic)
      }
    },
    removeTopic (index) {
      this.topics.splice(index, 1)
    }
  }
}
</script>
<style scoped>
  /deep/ .vue-autocomplete-input {
    width: 100%
  }
</style>