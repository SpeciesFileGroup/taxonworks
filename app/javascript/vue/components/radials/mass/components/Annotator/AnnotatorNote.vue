<template>
  <div class="label-above">
    <label>Note</label>
    <textarea
      class="full_width margin-medium-bottom"
      rows="5"
      v-model="note"
    />
    <VBtn
      medium
      color="create"
      @click="createNote"
    >
      Create
    </VBtn>
    <ConfirmationModal
      ref="confirmationModalRef"
      :container-style="{ 'min-width': 'auto', width: '300px' }"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Note } from '@/routes/endpoints'
import VBtn from '@/components/ui/VBtn/index.vue'
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import confirmationOpts from '../../constants/confirmationOpts.js'

const props = defineProps({
  objectType: {
    type: String,
    required: true
  },

  ids: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['create'])

const confirmationModalRef = ref(null)
const note = ref('')

async function createNote() {
  const ok = await confirmationModalRef.value.show(confirmationOpts)

  if (ok) {
    const promises = props.ids.map((id) => {
      const payload = {
        text: note.value,
        note_object_id: id,
        note_object_type: props.objectType
      }

      return Note.create({ note: payload })
    })

    Promise.all(promises).then(() => {
      TW.workbench.alert.create(
        'Note item(s) were successfully created',
        'notice'
      )
      emit(
        'create',
        promises.map((r) => r.body)
      )
    })
  }
}
</script>
