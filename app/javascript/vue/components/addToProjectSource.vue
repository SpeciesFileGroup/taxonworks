<template>
  <button
      v-if="!createdSourceID"
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
      id: {                           // this is a Source ID
        type: [Number, String],
        required: true
      },
      project_source_id: {
        type: [Number, String],
      }
    },
    data() {
      return {
        project_source: {
          source_id: this.id          // this is a Source ID
        },
        createdSourceID: undefined    // this is a ProjectSource ID
      }
    },
    methods: {
      create() {
        this.$http.post('/project_sources.json', {project_source: this.project_source}).then(response => {
          this.createdSourceID = response.body.id
        })
      },
      remove() {
        this.$http.delete(`/project_sources/${this.createdSourceID}.json`).then(response => {
          this.createdSourceID = undefined;
        })
      }
    },
    mounted: function () {
      this.createdSourceID = this.project_source_id;
    }
  }
</script>
