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
  </div>
</template>

<script>

import SmartSelector from 'components/smartSelector'

export default {
  components: {
    SmartSelector
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
    }
  }
}
</script>
<style scoped>
  /deep/ .vue-autocomplete-input {
    width: 100%
  }
</style>
