<template>
  <div>
    <h2>Tags</h2>
    <switch-component
      v-model="view"
      :options="options"
    />
    <div class="separate-top">
      <ul
        v-if="view !== 'search'"
        class="no_bullets">
        <li 
          v-for="keyword in smartLists[view]"
          :key="keyword.id"
          v-if="!keywords.map(item => { return item.id }).includes(keyword.id)">
          <label>
            <input 
              type="radio"
              @click="addKeyword(keyword)">
            <span v-html="keyword.object_tag"/>
          </label>
        </li>
      </ul>
      <autocomplete
        v-else
        url="/controlled_vocabulary_terms/autocomplete"
        param="term"
        label="label_html"
        :clear-after="true"
        :add-params="{'type[]' : 'Keyword'}"
        placeholder="Search a keyword"
        min="2"
        @getItem="addKeyword"
      />
    </div>
    <div class="field separate-top">
      <ul class="no_bullets table-entrys-list">
        <li
          class="middle flex-separate list-complete-item"
          v-for="(keyword, index) in keywords"
          :key="keyword.id">
          <span v-html="keyword.object_tag"/>
          <span
            class="btn-delete button-circle"
            @click="removeKeyword(index)"/>
        </li>
      </ul>
    </div>    
  </div>
</template>

<script>

import { GetKeywordSmartSelector } from '../../request/resources'
import SwitchComponent from 'components/switch'
import Autocomplete from 'components/autocomplete'

export default {
  components: {
    SwitchComponent,
    Autocomplete
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
      keywords: [],
      view: undefined,
      options: [],
      smartLists: {}
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
    GetKeywordSmartSelector().then(response => {
      this.smartLists = response.body
      this.options = Object.keys(response.body)
      this.options.push('search')
    })
  },
  methods: {
    addKeyword (keyword) {
      if(keyword.hasOwnProperty('label_html')) {
        keyword.object_tag = keyword.label_html
      }
      this.keywords.push(keyword)
      this.keywordIds.push(keyword.id)
    },
    removeKeyword(index) {
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
