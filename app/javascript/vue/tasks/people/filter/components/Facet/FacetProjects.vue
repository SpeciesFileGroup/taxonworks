<template>
  <div>
    <h3>Project scope</h3>
    <div class="flex-separate margin-medium-bottom">
      <div class="fields">
        <label>
          <input type="checkbox">
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
            >
            {{ project.name }}
          </label>
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { User } from 'routes/endpoints'
import { getCurrentUserId } from 'helpers/user.js'
import { URLParamsToJSON } from 'helpers/url/parse'
import VToggle from 'tasks/observation_matrices/new/components/newMatrix/switch.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get () {
    return props.modelValue
  },

  set (value) {
    emit('update:modelValue', value)
  }
})

const projectIds = ref([])
const projects = ref([])
const isExcept = ref(false)

watch(
  [
    projectIds,
    isExcept
  ],
  _ => {
    console.log("E")
    params.value.except_project_id = isExcept.value
      ? [...projectIds.value]
      : []

    params.value.project_id = isExcept.value
      ? []
      : [...projectIds.value]
  },
  { deep: true }
)

User.find(getCurrentUserId(), { extend: ['projects'] }).then(r => {
  projects.value = r.body?.projects || []
})

const {
  except_project_id: exceptIds = [],
  project_id: ids = []
} = URLParamsToJSON(location.href)

isExcept.value = !!exceptIds.length
params.value.project_id = ids
params.value.except_project_id = exceptIds
</script>
