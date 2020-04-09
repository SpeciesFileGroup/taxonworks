<template>
  <div>
    <h2>Tags</h2>
    <fieldset>
      <legend>Tags</legend>
      <smart-selector
        autocomplete-url="/controlled_vocabulary_terms/autocomplete"
        :autocomplete-params="{'type[]' : 'Keyword'}"
        get-url="/controlled_vocabulary_terms/"
        model="keywords"
        klass="CollectionObject"
        pin-section="Keywords"
        pin-type="Keyword"
        @selected="addKeyword"/>
    </fieldset>
    <display-list
      :list="keywords"
      label="object_tag"
      @deleteIndex="removeKeyword"
      />
  </div>
</template>

<script>

import SmartSelector from 'components/smartSelector'
import DisplayList from 'components/displayList'

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
      keywords: []
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
  methods: {
    addKeyword (keyword) {
      if (!this.params.includes(keyword.id)) {
        this.keywords.push(keyword)
      }
    },
    removeKeyword (index) {
      this.keywords.splice(index, 1)
    }
  }
}
</script>
<style scoped>
  /deep/ .vue-autocomplete-input {
    width: 100%
  }
</style>
