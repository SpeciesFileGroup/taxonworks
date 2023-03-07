<template>
  <FacetContainer>
    <h3>Project scope</h3>
    <div class="flex-separate margin-medium-bottom">
      <div class="fields">
        <label>
          <input
            type="checkbox"
            v-model="currentProjectOnly"
          />
          Current only
        </label>
      </div>
      <VToggle
        v-model="isExcept"
        :options="['Not used in project', 'Used in project']"
      />
    </div>
    <div>
      <ul class="no_bullets">
        <li
          v-for="project in projects"
          :key="project.id"
        >
          <label>
            <input
              v-model="projectIds"
              :value="project.id"
              type="checkbox"
            />
            {{ project.name }}
          </label>
        </li>
      </ul>
    </div>
  </FacetContainer>
</template>

<script setup>
import { ref, computed, watch, onBeforeMount } from 'vue'
import { User } from 'routes/endpoints'
import { getCurrentUserId } from 'helpers/user.js'
import { getCurrentProjectId } from 'helpers/project.js'
import VToggle from 'tasks/observation_matrices/new/components/newMatrix/switch.vue'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get() {
    return props.modelValue
  },

  set(value) {
    emit('update:modelValue', value)
  }
})

const currentProjectId = Number(getCurrentProjectId())

const projectIds = ref([])
const projects = ref([])
const isExcept = ref(false)

const currentProjectOnly = computed({
  get: () =>
    projectIds.value.length === 1 &&
    projectIds.value.includes(currentProjectId),
  set: (isChecked) => {
    projectIds.value = isChecked
      ? [currentProjectId]
      : projectIds.value.filter((id) => id !== currentProjectId)
  }
})

onBeforeMount(() => {
  const userId = getCurrentUserId()
  const exceptIds = params.value.except_project_id || []
  const onlyIds = params.value.only_project_id || []

  User.find(userId, { extend: ['projects'] }).then(({ body }) => {
    projects.value = body?.projects || []
  })

  isExcept.value = !!params.value.except_project_id?.length
  projectIds.value = [...exceptIds, ...onlyIds]
})

watch(
  [projectIds, isExcept],
  (_) => {
    params.value.except_project_id = isExcept.value ? [...projectIds.value] : []
    params.value.only_project_id = isExcept.value ? [] : [...projectIds.value]
  },
  { deep: true }
)
</script>
