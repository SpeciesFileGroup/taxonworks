<template>
  <div>
    <h3>Citation topics</h3>
    <fieldset>
      <legend>Topics</legend>
      <smart-selector
        :autocomplete-params="{'type[]' : 'Topic'}"
        model="topics"
        target="Citation"
        klass="Topic"
        autocomplete-url="/controlled_vocabulary_terms/autocomplete"
        get-url="/controlled_vocabulary_terms/"
        :custom-list="allTopics"
        @selected="addTopic"/>
    </fieldset>
    <display-list
      :list="topics"
      label="object_tag"
      :delete-warning="false"
      @deleteIndex="removeTopic"/>
  </div>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector'
import DisplayList from 'components/displayList'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { GetKeyword } from '../../request/resources'
import { ControlledVocabularyTerm } from 'routes/endpoints'

export default {
  components: {
    SmartSelector,
    DisplayList
  },

  props: {
    modelValue: {
      type: Array,
      default: () => []
    }
  },

  emits: ['update:modelValue'],

  computed: {
    params: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  data () {
    return {
      topics: [],
      allTopics: undefined
    }
  },
  watch: {
    modelValue (newVal, oldVal) {
      if (!newVal.length && oldVal.length) {
        this.topics = []
      }
    },

    topics: {
      handler (newVal) {
        this.params = this.topics.map(topic => topic.id)
      },
      deep: true
    }
  },

  mounted () {
    const urlParams = URLParamsToJSON(location.href)

    ControlledVocabularyTerm.where({ type: ['Topic'] }).then(response => {
      this.allTopics = { all: response.body }
    })

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
  :deep(.vue-autocomplete-input) {
    width: 100%
  }
</style>
