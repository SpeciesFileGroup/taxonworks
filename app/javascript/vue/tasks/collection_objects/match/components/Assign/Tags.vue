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
      @selected="addTag"/>
  </div>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector'
import { CreateTag } from '../../request/resources'
import SpinnerComponent from 'components/spinner'

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
    addTag (selectedTag, position = 0) {
      let promises = []

      for(let i = 0; i < this.maxPerCall; i++) {
        if(position < this.ids.length) {
          promises.push(new Promise((resolve, reject) => {
            const tag = {
              keyword_id: selectedTag.id,
              tag_object_id: this.ids[i],
              tag_object_type: 'CollectionObject'
            }
            CreateTag(tag).then(response => {
              resolve()
            }, () => {
              resolve()
            })
          }))
          position++
        }
      }
      Promise.all(promises).then(response => {
        if(position < this.ids.length)
          this.addTag(selectedTag, position)
        else {
          this.isSaving = false
          TW.workbench.alert.create('Tag items was successfully created.', 'notice')
        }
      })
    },
  }
}
</script>
