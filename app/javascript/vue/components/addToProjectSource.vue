<template>
  <VBtn
    v-if="!createdSourceID"
    color="create"
    class="btn-add-to-project circle-button"
    title="Add to project"
    @click="addToProject"
  />

  <VBtn
    v-else
    color="destroy"
    class="btn-remove-from-project circle-button"
    title="Remove from project"
    @click="removeFromProject"
  />
</template>

<script setup>
import { ref, watch } from 'vue'
import { ProjectSource } from 'routes/endpoints'
import VBtn from 'components/ui/VBtn/index.vue'

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
    TW.workbench.alert.create('Source was added to project successfully', 'notice')
  })
}

const removeFromProject = () => {
  ProjectSource.destroy(createdSourceID.value).then(_ => {
    createdSourceID.value = undefined
    TW.workbench.alert.create('Source was removed from project successfully', 'notice')
  })
}

watch(
  () => props.projectSourceId,
  newVal => { createdSourceID.value = newVal },
  { immediate: true }
)

</script>
