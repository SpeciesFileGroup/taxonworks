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
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Note } from 'routes/endpoints'
import VBtn from 'components/ui/VBtn/index.vue'

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

const note = ref('')

function createNote () {
  const promises = props.ids.map(id => {
    const payload = {
      text: note.value,
      note_object_id: id,
      note_object_type: props.objectType
    }

    return Note.create({ note: payload })
  })

  Promise.all(promises).then(_ => {
    TW.workbench.alert.create('Note item(s) were successfully created', 'notice')
  })
}
</script>
