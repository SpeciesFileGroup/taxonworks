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
      @selected="repository = $event"
    />

    <smart-selector-item
      :item="repository"
      @unset="repository = undefined"
    />

    <div class="margin-medium-top">
      <button
        type="button"
        class="button normal-input button-submit"
        :disabled="!repository"
        @click="setRepository()"
      >
        Set repository
      </button>
    </div>
  </div>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector'
import SmartSelectorItem from 'components/ui/SmartSelectorItem.vue'
import SpinnerComponent from 'components/spinner'
import { CollectionObject } from 'routes/endpoints'

export default {
  components: {
    SmartSelector,
    SpinnerComponent,
    SmartSelectorItem
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
      isSaving: false,
      repository: undefined
    }
  },

  methods: {
    setRepository (repositoryId = this.repository.id, arrayIds = this.ids.slice()) {
      const ids = arrayIds.splice(0, this.maxPerCall)
      const requests = ids.map(id => CollectionObject.update(id, {
        collection_object: {
          repository_id: repositoryId
        }
      }))

      Promise.allSettled(requests).then(() => {
        if (arrayIds.length) {
          this.setRepository(repositoryId, arrayIds)
        } else {
          this.isSaving = false
          TW.workbench.alert.create('Repository was successfully set.', 'notice')
        }
      })
    }
  }
}
</script>
