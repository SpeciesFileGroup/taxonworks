<template>
  <div class="panel content">
    <spinner-component
      v-if="isSaving"
      legend="Saving..."
    />
    <h2>Repository</h2>
    <smart-selector
      model="repositories"
      klass="Repository"
      target="CollectionObject"
      @selected="setRepository"
    />
  </div>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector'
import SpinnerComponent from 'components/spinner'
import { CollectionObject } from 'routes/endpoints'

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
      maxPerCall: 5,
      isSaving: false
    }
  },

  methods: {
    setRepository (repository, arrayIds = this.ids) {
      const ids = arrayIds.splice(0, this.maxPerCall)
      const requests = ids.map(id => CollectionObject.update(id, {
        collection_object: {
          repository_id: repository.id
        }
      }))

      Promise.allSettled(requests).then(() => {
        if (arrayIds.length) {
          this.addTag(repository, arrayIds)
        } else {
          this.isSaving = false
          TW.workbench.alert.create('Tag items was successfully created.', 'notice')
        }
      })
    }
  }
}
</script>
