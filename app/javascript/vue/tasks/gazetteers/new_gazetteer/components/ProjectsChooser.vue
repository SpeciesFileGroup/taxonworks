<template>
  <fieldset v-if="isLoading || projects.length > 0">
    <VSpinner v-if="isLoading" />

    <legend>Projects</legend>
    <div class="projects-text">{{ selectionText }}</div>

    <ul
      v-if="!gz_id"
      class="no_bullets"
    >
      <li v-for="p in projects">
        <label>
          <input
            type="checkbox"
            :value="p.id"
            v-model="selectedProjects"
            :disabled="p.id == currentProject"
          />
          {{ p.name }}
        </label>
      </li>
    </ul>
  </fieldset>
</template>

<script setup>
import { getCurrentProjectId } from '@/helpers/project.js'
import { getCurrentUserId } from '@/helpers'
import { User } from '@/routes/endpoints'
import { onMounted, ref, watch} from 'vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const currentProject = Number(getCurrentProjectId())
const projects = ref([])
const selectedProjects = defineModel()
const isLoading = ref(true)

const props = defineProps({
  selectionText: {
    type: String,
    default: ''
  }
})

watch(
  () => selectedProjects.value.length,
  (newLength) => {
    if (newLength == 0) {
      // The current project should always be checked
      selectedProjects.value = [currentProject]
    }
  }
)

onMounted(() => {
  isLoading.value = true
  User.projects(getCurrentUserId())
    .then(({ body }) => {
      projects.value = body
      selectedProjects.value = [currentProject]
    })
    .finally(() => { isLoading.value = false })
})

</script>

<style lang="scss" scoped>
.shape-input {
  width: 400px;
  padding: 1.5em;
  margin-bottom: 1.5em;
  margin-top: 1.5em;
  margin-right: 1em;
}

.union-inputs {
  display: flex;
  flex-wrap: wrap;
}

.projects-text {
  margin-bottom: .5em;
}
</style>