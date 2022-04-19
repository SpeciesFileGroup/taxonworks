<template>
  <div class="panel content panel-section">
    <div>
      <h2>Tags</h2>
    </div>
    <smart-selector
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{'type[]' : 'Keyword'}"
      get-url="/controlled_vocabulary_terms/"
      model="keywords"
      klass="Image"
      target="Image"
      @selected="addTag"
    />
    <table-list
      v-if="tags.length"
      class="margin-medium-top"
      :list="tags"
      :header="['Tags', 'Remove']"
      :delete-warning="false"
      :annotator="false"
      :attributes="['object_tag']"
      @delete="removeTag"
    />
  </div>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector'
import TableList from 'components/table_list'
import { MutationNames } from '../../store/mutations/mutations'
import { GetterNames } from '../../store/getters/getters'
import { addToArray } from 'helpers/arrays'

export default {
  components: {
    SmartSelector,
    TableList
  },

  computed: {
    tags: {
      get () {
        return this.$store.getters[GetterNames.GetTagsForImage]
      },
      set (value) {
        this.$store.commit(MutationNames.SetTagsForImage, value)
      }
    }
  },

  methods: {
    addTag (tag) {
      addToArray(this.tags, tag)
    },

    removeTag (tag) {
      this.tags.splice(this.tags.findIndex(item => item.id === tag.id), 1)
    }
  }

}
</script>
