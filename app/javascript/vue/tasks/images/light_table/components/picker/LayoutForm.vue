<template>
  <form
    class="flex-col gap-small"
    @submit.prevent="submit"
  >
    <div class="field label-above">
      <label for="light-table-name">Name</label>
      <input
        id="light-table-name"
        v-model="name"
        type="text"
        class="full_width"
      />
    </div>
    <div class="field label-above">
      <label for="light-table-description">Description</label>
      <textarea
        id="light-table-description"
        v-model="description"
        class="full_width"
        rows="3"
      />
    </div>
    <div>
      <VBtn
        color="create"
        medium
        type="submit"
        :disabled="!name.trim() || isSaving"
      >
        Create
      </VBtn>
    </div>
  </form>
</template>

<script setup>
import { ref } from 'vue'
import { Composition } from '@/routes/endpoints'
import { COMPOSITION_TYPE } from '../../constants'
import VBtn from '@/components/ui/VBtn/index.vue'

const emit = defineEmits(['create'])

const name = ref('')
const description = ref('')
const isSaving = ref(false)

function submit() {
  isSaving.value = true

  Composition.create({
    composition: {
      name: name.value.trim(),
      description: description.value.trim() || null,
      type: COMPOSITION_TYPE
    }
  })
    .then(({ body }) => {
      name.value = ''
      description.value = ''
      emit('create', body)
    })
    .catch(() => {})
    .finally(() => {
      isSaving.value = false
    })
}
</script>
