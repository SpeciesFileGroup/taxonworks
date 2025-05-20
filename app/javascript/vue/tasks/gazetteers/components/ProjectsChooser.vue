<template>
  <fieldset v-if="isLoading || projects.length > 1">
    <VSpinner v-if="isLoading" />

    <legend>Projects</legend>
    <div class="projects-text">{{ selectionText }}</div>

    <ul class="no_bullets">
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
const isLoading = ref(false)

const selectedProjects = defineModel()

const props = defineProps({
  selectionText: {
    type: String,
    default: ''
  },
  projectsUserIsMemberOf: {
    type: Array,
    default: () => []
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
  if (props.projectsUserIsMemberOf.length > 0) {
    setInitialValues(props.projectsUserIsMemberOf)
    return
  }

  isLoading.value = true
  User.projects(getCurrentUserId())
    .then(({ body }) => {
      setInitialValues(body)
    })
    .finally(() => { isLoading.value = false })
})

function setInitialValues(projectList) {
  projects.value = projectList
  if (selectedProjects.value.length == 0) {
   selectedProjects.value = [currentProject]
  }
}
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