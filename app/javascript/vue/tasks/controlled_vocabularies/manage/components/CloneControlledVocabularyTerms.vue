<template>
  <VBtn
    color="primary"
    medium
    @click="() => (isModalVisible = true)"
  >
    Clone {{ type }} from project
  </VBtn>
  <VModal
    v-if="isModalVisible"
    @close="() => (isModalVisible = false)"
    :container-style="{ width: '400px' }"
  >
    <template #header>
      <h3>Clone from project</h3>
    </template>
    <template #body>
      <label class="display-block">Project</label>
      <select v-model="projectId">
        <option
          disabled
          selected
        >
          Select a project...
        </option>
        <option
          v-for="item in list"
          :key="item.id"
          :value="item.id"
        >
          {{ item.name }}
        </option>
      </select>
      <VBtn
        class="margin-small-left"
        color="create"
        medium
        :disabled="!projectId"
        @click="clone()"
      >
        Clone
      </VBtn>
    </template>
  </VModal>
</template>

<script setup>
import { ref, watch } from 'vue'
import { User, ControlledVocabularyTerm } from '@/routes/endpoints'
import { getCurrentUserId } from '@/helpers'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  type: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['clone'])

const list = ref([])
const projectId = ref()
const isModalVisible = ref(false)

function loadProjects() {
  const userId = getCurrentUserId()

  User.projects(userId).then(({ body }) => {
    list.value = body
  })
}

watch(isModalVisible, () => {
  if (isModalVisible.value && !list.value.length) {
    loadProjects()
  }
})

function clone() {
  ControlledVocabularyTerm.cloneFromProject({
    target: props.type,
    project_id: projectId.value
  })
    .then(() => {
      emit('clone')
    })
    .catch(() => {})
}
</script>
