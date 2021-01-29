<template>
  <div>
    <h3>Tags</h3>
    <smart-selector
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{'type[]' : 'Keyword'}"
      get-url="/controlled_vocabulary_terms/"
      model="keywords"
      klass="Tag"
      @selected="addKeyword"/>
    <div class="field separate-top">
      <ul class="no_bullets table-entrys-list">
        <li
          class="middle flex-separate list-complete-item"
          v-for="(keyword, index) in keywords"
          :key="keyword.id">
          <span v-html="keyword.object_tag"/>
          <span
            class="btn-delete button-circle button-default"
            @click="removeKeyword(index)"/>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>

import SmartSelector from 'components/smartSelector'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { GetKeyword } from '../../request/resources'

export default {
  components: {
    SmartSelector
  },
  props: {
    value: {
      type: Array,
      required: true
    }
  },
  computed: {
    keywordIds: {
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
      keywords: []
    }
  },
  watch: {
    value: {
      handler (newVal) {
        if(!newVal.length) {
          this.keywords = []
        }
      },
      deep: true
    }
  },
  mounted () {
    const params = URLParamsToJSON(location.href)
    if (params.keyword_ids) {
      params.keyword_ids.forEach(id => {
        GetKeyword(id).then(response => {
          this.addKeyword(response.body)
        })
      })
    }
  },
  methods: {
    addKeyword (keyword) {
      this.keywords.push(keyword)
      this.keywordIds.push(keyword.id)
    },
    removeKeyword (index) {
      this.keywords.splice(index, 1)
      this.keywordIds.splice(index, 1)
    }
  }
}
</script>

<style scoped>
  /deep/ .vue-autocomplete-input {
    width: 100%
  }
</style>
