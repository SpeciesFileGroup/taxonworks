<template>
  <span
    v-if="!createdSourceID"
    @click="create"
    title="Add to project"
    class="button circle-button button-submit btn-add-to-project">
    Add to project
  </span>
  <span
    v-else
    @click="remove"
    title="Remove from project"
    class="button circle-button button-delete btn-remove-from-project">
    Remove from project
  </span>
</template>

<script>

import AjaxCall from 'helpers/ajaxCall'

export default {
  props: {
    id: {
      type: [Number, String],
      required: true
    },
    projectSourceId: {
      type: [Number, String]
    }
  },

  data () {
    return {
      project_source: {
        source_id: this.id
      },
      createdSourceID: undefined
    }
  },

  methods: {
    create () {
      AjaxCall('post', '/project_sources.json', {project_source: this.project_source}).then(response => {
        this.createdSourceID = response.body.id
        TW.workbench.alert.create('Source was added to project successfully', 'notice')
      })
    },
    remove () {
      AjaxCall('delete', `/project_sources/${this.createdSourceID}.json`).then(response => {
        this.createdSourceID = undefined
        TW.workbench.alert.create('Source was removed from project successfully', 'notice')
      })
    }
  },

  mounted () {
    this.createdSourceID = this.projectSourceId
  }
}
</script>
