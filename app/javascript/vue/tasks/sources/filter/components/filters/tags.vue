<template>
  <div>
    <h3>Tags</h3>
    <fieldset>
      <legend>Keywords</legend>
      <smart-selector
        autocomplete-url="/controlled_vocabulary_terms/autocomplete"
        :autocomplete-params="{'type[]' : 'Keyword'}"
        get-url="/controlled_vocabulary_terms/"
        model="keywords"
        klass="CollectionObject"
        pin-section="Keywords"
        pin-type="Keyword"
        :custom-list="tags"
        @selected="addKeyword"/>
    </fieldset>
    <display-list
      :list="keywords"
      label="object_tag"
      :delete-warning="false"
      @deleteIndex="removeKeyword"
    />
  </div>
</template>

<script>

import SmartSelector from 'components/smartSelector'
import DisplayList from 'components/displayList'
import { GetKeyword } from '../../request/resources'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import ajaxCall from 'helpers/ajaxCall.js'

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
      keywords: [],
      tags: undefined
    }
  },
  watch: {
    value (newVal, oldVal) {
      if (!newVal.length && oldVal.length) {
        this.keywords = []
      }
    },
    keywords: {
      handler (newVal) {
        this.params = this.keywords.map(keyword => { return keyword.id })
      },
      deep: true
    }
  },
  mounted () {
    const urlParams = URLParamsToJSON(location.href)
    this.loadTags('Keyword')
    if (urlParams.keyword_ids) {
      urlParams.keyword_ids.forEach(id => {
        GetKeyword(id).then(response => {
          this.addKeyword(response.body)
        })
      })
    }
  },
  methods: {
    addKeyword (keyword) {
      if (!this.params.includes(keyword.id)) {
        this.keywords.push(keyword)
      }
    },
    removeKeyword (index) {
      this.keywords.splice(index, 1)
    },
    loadTags (type) {
      ajaxCall('get', `/controlled_vocabulary_terms.json?type[]=${type}`).then(response => {
        this.tags = { all: response.body }
      })
    }
  }
}
</script>
<style scoped>
  /deep/ .vue-autocomplete-input {
    width: 100%
  }
</style>
