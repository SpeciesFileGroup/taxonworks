<template>
  <fieldset>
    <legend>Tags</legend>
    <smart-selector
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{'type[]' : 'Keyword'}"
      get-url="/controlled_vocabulary_terms/"
      model="keywords"
      klass="Image"
      @selected="addTag"/>
    <table-list
      v-if="tags.length"
      :list="tags"
      :header="['Tags', 'Remove']"
      :delete-warning="false"
      :annotator="false"
      @delete="removeTag"
      :attributes="['object_tag']"/>
  </fieldset>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector'
import TableList from 'components/table_list'
import { MutationNames } from '../store/mutations/mutations'
import { GetterNames } from '../store/getters/getters'

export default {
  components: {
    SmartSelector,
    TableList
  },

  computed: {
    tags: {
      get () {
        return this.$store.getters[GetterNames.GetTags]
      },
      set (value) {
        this.$store.commit(MutationNames.SetTags, value)
      }
    }
  },

  methods: {
    addTag (tag) {
      this.$store.commit(MutationNames.AddTag, tag)
    },
    removeTag (tag) {
      this.tags.splice(this.tags.findIndex(item => item.id === tag.id), 1)
    }
  }

}
</script>
