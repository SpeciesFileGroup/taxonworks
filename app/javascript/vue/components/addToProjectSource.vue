<template>
  <VBtn
    v-if="!createdSourceID"
    color="create"
    circle
    title="Add to project"
    aria-label="Add to project"
    @click="addToProject"
  >
    <VIcon
      name="folderArrowUp"
      x-small
    />
  </VBtn>

  <VBtn
    v-else
    color="destroy"
    circle
    title="Remove from project"
    aria-label="Remove from project"
    @click="removeFromProject"
  >
    <VIcon
      name="folderArrowUp"
      x-small
    />
  </VBtn>
</template>

<script setup>
import { ref, watch } from 'vue'
import { ProjectSource } from '@/routes/endpoints'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

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
