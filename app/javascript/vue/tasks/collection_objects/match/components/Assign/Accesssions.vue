<template>
  <div class="panel content">
    <spinner-component
      v-if="isSaving"
      legend="Saving..."/>
    <h2>Accessions/Deaccession</h2>
    <div class="field label-above">
      <label>Accesssioned at</label>
      <input
        type="date"
        v-model="form.accessioned_at">
    </div>
    <div class="field label-above">
      <label>Deaccesssioned at</label>
      <input
        type="date"
        v-model="form.deaccessioned_at">
    </div>
    <div class="field label-above">
      <label>Deaccession reason</label>
      <input
        type="text"
        v-model="form.deaccession_reason">
    </div>
    <div>
      <button
        type="button"
        class="button normal-input button-submit"
        @click="updateCO()">
        Set
      </button>
    </div>
  </div>
</template>

<script>

import SpinnerComponent from 'components/spinner'
import { CollectionObject } from 'routes/endpoints'

export default {
  components: {
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
      isSaving: false,
      form: {
        accessioned_at: undefined,
        deaccessioned_at: undefined,
        deaccession_reason: undefined
      }
    }
  },

  methods: {
    updateCO (selectedTag, arrayIds = this.ids) {
      const ids = arrayIds.slice(0, 5)
      const nextIds = arrayIds.slice(5)
      const promises = ids.map(id =>
        CollectionObject.update(id, {
          collection_object: {
            ...this.form
          }
        }))

      this.isSaving = true

      Promise.allSettled(promises).then(() => {
        if (nextIds.length) {
          this.updateCO(selectedTag, nextIds)
        } else {
          this.isSaving = false
          TW.workbench.alert.create('Collection objects were successfully updated.', 'notice')
        }
      })
    }
  }
}

</script>
