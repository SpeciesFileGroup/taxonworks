<template>
  <button 
    v-if="!createdSource"
    @click="create"
    type="button"
    class="button normal-input button-submit">
    Add to project
  </button>
  <button
    v-else
    @click="remove"
    type="button"
    class="button normal-input button-delete">
    Remove from project
  </button>
</template>

<script>
export default {
  props: {
    id: {
      type: [Number, String],
      required: true
    }
  },
  data() {
    return {
      project_source: {
        source_id: this.id
      },
      createdSource: undefined
    }
  },
  methods: {
    create() {
      
      this.$http.post('/project_sources.json', { project_source: this.project_source }).then(response => {
        this.createdSource = response.body
      })
    },
    remove() {
      this.$http.delete(`/project_sources/${this.createdSource.id}.json`).then(response => {
        this.createdSource = undefined
      })
    }
  }
}
</script>
