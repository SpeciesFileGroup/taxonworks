<template>
  <div class="depiction_annotator">
    <div class="flex-wrap-column gap-medium">
      <input
        class="normal-input"
        type="text"
        v-model="anatomicalPart.name"
        placeholder="Name"
      />

      or

      <input
        class="normal-input"
        type="text"
        v-model="anatomicalPart.uri"
        placeholder="URI"
      />
      <input
        class="normal-input"
        type="text"
        v-model="anatomicalPart.uri_label"
        placeholder="URI label"
      />

      <div class="horizontal-left-content gap-small">
        <VBtn
          :disabled="!validAnatomicalPart"
          color="create"
          medium
          @click="save"
        >
          {{ anatomicalPart.id ? 'Update' : 'Create' }}
        </VBtn>

        <VBtn
          color="primary"
          medium
          @click="() => (anatomicalPart = {})"
        >
          New
        </VBtn>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { AnatomicalPart } from '@/routes/endpoints'
import VBtn from '@/components/ui/VBtn/index.vue'

const anatomicalPart = ref({})

const emit = defineEmits(['create'])

const validAnatomicalPart = computed(() => {
  return anatomicalPart.value.name ||
    (anatomicalPart.value.uri && anatomicalPart.value.uri_label)
})

function save() {
  const response = anatomicalPart.id
    ? AnatomicalPart.update(anatomicalPart.id,
      { anatomical_part: anatomicalPart.value })
    : AnatomicalPart.create({ anatomical_part: anatomicalPart.value })

  response
    .then(({ body }) => {
      resetForm()
      emit('create', body)
      TW.workbench.alert.create('Anatomical part was successfully saved.', 'notice')
    })
    .catch(() => {})
}

function resetForm() {
  anatomicalPart.value = {}
}
</script>
