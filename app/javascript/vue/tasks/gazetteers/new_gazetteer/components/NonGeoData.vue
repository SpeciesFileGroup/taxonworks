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

    <ProjectsButton
      v-if="projectsUserIsMemberOf.length > 1"
      :gz="gz"
      :projects-user-is-member-of="projectsUserIsMemberOf"
      v-model="selectedProjects"
    />

  </div>

</template>

<script setup>
import ProjectsButton from './ProjectsButton.vue'

const props = defineProps({
  projectsUserIsMemberOf: {
    type: Array,
    default: () => []
  }
})

const gz = defineModel('gz', {type: Object, required: true})
const selectedProjects = defineModel('projects', {type: Array, required: true})

</script>

<style scoped>

</style>