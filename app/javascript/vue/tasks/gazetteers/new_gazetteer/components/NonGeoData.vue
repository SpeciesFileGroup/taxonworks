<template>
  <div>
    <div class="field label-above">
      <label>Name</label>
      <input
        type="text"
        class="normal-input name-input"
        v-model="gz.name"
      />
    </div>

    <div class="field label-above">
      <label>ISO 3166 A2 country code</label>
      <input
        type="text"
        class="input-xsmall-width"
        v-model="gz.iso_3166_a2"
      />
    </div>

    <div class="field label-above">
      <label>ISO 3166 A3 country code</label>
      <input
        type="text"
        class="input-xsmall-width"
        v-model="gz.iso_3166_a3"
      />
    </div>

    <ProjectsChooser
      v-if="!gz.id"
      v-model="selectedProjects"
      selection-text="Select projects to save this gazetteer to."
    />
  </div>

</template>

<script setup>
import ProjectsChooser from '../../components/ProjectsChooser.vue'

const gz = defineModel('gz', {type: Object, required: true})
const selectedProjects = defineModel('projects', {type: Array, required: true})

</script>

<style scoped>

</style>