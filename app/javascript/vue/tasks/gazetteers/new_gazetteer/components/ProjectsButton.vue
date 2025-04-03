<template>
  <div>
    <div>
      <button
        v-if="!gz.id"
        class="button normal-input button-default"
        @click="() => (showProjects = true)"
      >
        {{ projectsButtonText }}
      </button>
    </div>

    <VModal
      v-if="showProjects"
      @close="() => {
        showProjects = false
      }"
      :container-style="{
        width: '600px',
        height: '80vh'
      }"
    >
      <template #header>
        <slot name="header">
          <h3>Select projects to save this gazetteer to</h3>
        </slot>
      </template>

      <template #body>
        <ProjectsChooser
          :projects-user-is-member-of="projectsUserIsMemberOf"
          v-model="selectedProjects"
          selection-text=""
        />
      </template>
    </VModal>
  </div>
</template>

<script setup>
import ProjectsChooser from '../../components/ProjectsChooser.vue'
import VModal from '@/components/ui/Modal.vue'
import { computed, ref } from 'vue'

const props = defineProps({
  gz: {
    type: Object,
    default: () => ({})
  },
  projectsUserIsMemberOf: {
    type: Array,
    default: () => []
  }
})

const showProjects = ref(false)

const selectedProjects = defineModel({type: Array, required: true})

const projectsButtonText = computed(() => {
  // The current project is always selected, even if selectedProjects doesn't
  // know it yet.
  return `Projects (${selectedProjects.value.length || 1})`
})
</script>

