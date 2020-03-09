<template>
  <div class="panel content">
    <h2>Tags</h2>
    <smart-selector
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{'type[]' : 'Keyword'}"
      get-url="/controlled_vocabulary_terms/"
      model="keywords"
      klass="Image"
      @selected="addTag"/>
  </div>
</template>

<script>

import SmartSelector from 'components/smartSelector'
import { CreateTag } from '../../request/resources'

export default {
  components: {
    SmartSelector
  },
  props: {
    ids: {
      type: Array,
      required: true
    }
  },
  data () {
    return {
      view: undefined,
    }
  },
  methods: {
    async addTag (tag) {
      for(let i = 0; i < this.ids.length; i++) {
        const tag = {
          keyword_id: tag.id,
          tag_object_id: this.ids[i], 
          tag_object_type: 'CollectionObject'
        }
        await CreateTag(tag)
      }
    }
  }
}
</script>
