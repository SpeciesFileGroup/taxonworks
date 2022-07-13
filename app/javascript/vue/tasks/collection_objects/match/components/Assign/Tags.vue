<template>
  <div class="panel content">
    <spinner-component
      v-if="isSaving"
      legend="Saving..."
    />
    <h2>Tags</h2>
    <smart-selector
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{'type[]' : 'Keyword'}"
      get-url="/controlled_vocabulary_terms/"
      model="keywords"
      klass="Tag"
      target="CollectionObject"
      @selected="addTag"
    />

    <display-list
      :list="tags"
      :delete-warning="false"
      label="object_tag"
      soft-delete
      @delete-index="tags.splice(index, 1)"
    />

    <div class="margin-medium-top">
      <button
        type="button"
        class="button normal-input button-submit"
        :disabled="!tags.length"
        @click="setTags()"
      >
        Set tags
      </button>
    </div>
  </div>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector'
import SpinnerComponent from 'components/spinner'
import DisplayList from 'components/displayList.vue'
import { Tag } from 'routes/endpoints'

export default {
  components: {
    DisplayList,
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
      isSaving: false,
      tags: []
    }
  },

  methods: {
    addTag (tag) {
      this.tags.push(tag)
    },

    setTags () {
      const promises = this.tags.map(tag =>
        Tag.createBatch({
          keyword_id: tag.id,
          object_ids: this.ids,
          object_type: 'CollectionObject'
        })
      )

      this.isSaving = true

      Promise.allSettled(promises).then(() => {
        this.isSaving = false
        TW.workbench.alert.create('Tag items was successfully created.', 'notice')
      })
    }
  }
}
</script>
