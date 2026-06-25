<template>
  <VBtn
    v-if="!createdSourceID"
    color="create"
    icon
    variant="tonal"
    title="Add to project"
    aria-label="Add to project"
    @click="addToProject"
  >
    <IconFolderInput class="w-4 h-4" />
  </VBtn>

  <VBtn
    v-else
    color="destroy"
    icon
    variant="tonal"
    title="Remove from project"
    aria-label="Remove from project"
    @click="removeFromProject"
  >
    <IconFolderOutput class="w-4 h-4" />
  </VBtn>
</template>

<script setup>
import { ref, watch } from 'vue'
import { ProjectSource } from '@/routes/endpoints'
import VBtn from '@/components/ui/VBtn/index.vue'
import IconFolderInput from '@/components/Icon/IconFolderInput.vue'
import IconFolderOutput from '@/components/Icon/IconFolderOutput.vue'

const props = defineProps({
  id: {
    type: [Number, String],
    required: true
  },

  projectSourceId: {
    type: [Number, String],
    default: undefined
  }
})

const createdSourceID = ref(undefined)

const addToProject = () => {
  const payload = {
    project_source: {
      source_id: props.id
    }
  }

  ProjectSource.create(payload).then(({ body }) => {
    createdSourceID.value = body.id
    TW.workbench.alert.create(
      'Source was added to project successfully',
      'notice'
    )
  })
}

const removeFromProject = () => {
  ProjectSource.destroy(createdSourceID.value).then((_) => {
    createdSourceID.value = undefined
    TW.workbench.alert.create(
      'Source was removed from project successfully',
      'notice'
    )
  })
}

watch(
  () => props.projectSourceId,
  (newVal) => {
    createdSourceID.value = newVal
  },
  { immediate: true }
)
</script>
