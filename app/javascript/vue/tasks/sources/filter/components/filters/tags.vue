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
        klass="Tags"
        pin-section="Keywords"
        pin-type="Keyword"
        :target="target"
        :custom-list="allFiltered"
        @selected="addKeyword"/>
    </fieldset>
    <table
      v-if="keywords.length"
      class="vue-table">
      <thead>
        <tr>
          <th>Name</th>
          <th />
          <th />
        </tr>
      </thead>
      <transition-group
        name="list-complete"
        tag="tbody">
        <template
          v-for="(item, index) in keywords"
          :key="index"
          class="table-entrys-list">
          <row-item
            class="list-complete-item"
            :item="item"
            label="object_tag"
            :options="{
              AND: true,
              OR: false
            }"
            v-model="keywords[index].and"
            @remove="removeKeyword(index)"
          />
        </template>
      </transition-group>
    </table>
  </div>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector'
import RowItem from './shared/RowItem'
import { ControlledVocabularyTerm } from 'routes/endpoints'
import { URLParamsToJSON } from 'helpers/url/parse.js'

export default {
  components: {
    SmartSelector,
    RowItem
  },

  props: {
    modelValue: {
      type: Object,
      default: () => ({})
    },
    target: {
      type: String,
      required: true
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
    },

    allFiltered () {
      const keywordsId = this.keywords.map(({ id }) => id)
      return { all: this.tags.all.filter(item => !keywordsId.includes(item.id)) }
    }
  },
  data () {
    return {
      keywords: [],
      tags: { all: [] }
    }
  },

  watch: {
    modelValue (newVal) {
      if (!newVal.keyword_id_and.length && !newVal.keyword_id_or.length && this.keywords.length) {
        this.keywords = []
      }
    },
    keywords: {
      handler () {
        this.params = {
          keyword_id_and: this.keywords.filter(keyword => keyword.and).map(keyword => keyword.id),
          keyword_id_or: this.keywords.filter(keyword => !keyword.and).map(keyword => keyword.id)
        }
      },
      deep: true
    }
  },

  created () {
    const urlParams = URLParamsToJSON(location.href)
    const {
      keyword_id_and = [],
      keyword_id_or = []
    } = urlParams

    this.loadTags()

    keyword_id_and.forEach(id => {
      ControlledVocabularyTerm.find(id).then(response => {
        this.addKeyword(response.body, true)
      })
    })

    keyword_id_or.forEach(id => {
      ControlledVocabularyTerm.find(id).then(response => {
        this.addKeyword(response.body, false)
      })
    })
  },

  methods: {
    addKeyword (keyword, and = true) {
      if (!this.keywords.find(item => item.id === keyword.id)) {
        this.keywords.push({ ...keyword, and })
      }
    },

    removeKeyword (index) {
      this.keywords.splice(index, 1)
    },

    loadTags () {
      ControlledVocabularyTerm.where({ type: ['Keyword'] }).then(response => {
        this.tags = { all: response.body }
      })
    }
  }
}
</script>
<style scoped>
  :deep(.vue-autocomplete-input) {
    width: 100%
  }
</style>
