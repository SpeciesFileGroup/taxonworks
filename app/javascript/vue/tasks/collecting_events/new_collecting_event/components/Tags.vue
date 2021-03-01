<template>
  <div>
    <h3>Tags</h3>
    <smart-selector
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{'type[]' : 'Keyword'}"
      get-url="/controlled_vocabulary_terms/"
      model="keywords"
      klass="Tag"
      @selected="addTag"/>
    <display-list
      label="object_tag"
      :list="list"
      soft-delete
      :delete-warning="false"
      @deleteIndex="removeTag"/>
  </div>
</template>

<script>

import SmartSelector from 'components/smartSelector'
import DisplayList from 'components/displayList'

export default {
  components: {
    DisplayList,
    SmartSelector
  },

  props: {
    value: {
      type: Array,
      required: true
    }
  },

  computed: {
    list: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },

  methods: {
    addTag (tag) {
      this.list.push(tag)
    },

    removeTag (index) {
      this.list.splice(index, 1)
    }
  }
}
</script>
