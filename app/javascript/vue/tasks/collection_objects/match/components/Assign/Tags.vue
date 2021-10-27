<template>
  <div class="panel content">
    <spinner-component
      v-if="isSaving"
      legend="Saving..."/>
    <h2>Tags</h2>
    <smart-selector
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{'type[]' : 'Keyword'}"
      get-url="/controlled_vocabulary_terms/"
      model="keywords"
      klass="Tag"
      target="CollectionObject"
      @selected="addTag"/>
  </div>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector'
import SpinnerComponent from 'components/spinner'
import { Tag } from 'routes/endpoints'

export default {
  components: {
    SmartSelector,
    SpinnerComponent
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
      maxPerCall: 5,
      isSaving: false
    }
  },

  methods: {
    addTag (selectedTag, arrayIds = this.ids) {
      const ids = arrayIds.slice(0, 5)
      const nextIds = arrayIds.slice(5)
      const promises = ids.map(id => Tag.create({
        tag: {
          keyword_id: selectedTag.id,
          tag_object_id: id,
          tag_object_type: 'CollectionObject'
        }
      }))

      Promise.allSettled(promises).then(() => {
        if (nextIds.length) {
          console.log(nextIds)
          this.addTag(selectedTag, nextIds)
        } else {
          this.isSaving = false
          TW.workbench.alert.create('Tag items was successfully created.', 'notice')
        }
      })
    }
  }
}
</script>
