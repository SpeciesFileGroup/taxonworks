<template>
  <div class="notes_annotator">
    <EditingBanner
      v-if="note.id"
      :label="note.text"
      @close="note = newNote()"
    />
    <textarea
      class="separate-bottom"
      v-model="note.text"
      rows="10"
      placeholder="Text..."
    />
    <div class="horizontal-left-content gap-small margin-small-bottom">
      <VBtn
        medium
        color="create"
        :disabled="!validateFields"
        @click="saveNote()"
      >
        {{ note.id ? 'Update' : 'Create' }}
      </VBtn>
    </div>
    <DisplayList
      label="text"
      :list="list"
      edit
      @edit="(item) => (note = item)"
      @delete="removeItem"
    />
  </div>
</template>

<script setup>
import { Note } from '@/routes/endpoints'
import { ref, computed } from 'vue'
import { useSlice } from '@/components/radials/composables'
import DisplayList from '@/components/displayList.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import EditingBanner from '@/components/ui/EditingBanner/EditingBanner.vue'

const props = defineProps({
  objectId: {
    type: Number,
    required: true
  },

  objectType: {
    type: String,
    required: true
  },

  radialEmit: {
    type: Object,
    required: true
  }
})

const { list, addToList, removeFromList } = useSlice({
  radialEmit: props.radialEmit
})

const validateFields = computed(() => note.value.text)
const note = ref(newNote())

function newNote() {
  return {
    text: null,
    note_object_id: props.objectId,
    note_object_type: props.objectType
  }
}

function saveNote() {
  const request = note.value.id
    ? Note.update(note.value.id, { note: note.value })
    : Note.create({ note: note.value })

  request.then(({ body }) => {
    addToList(body)
  })
}

function removeItem(item) {
  Note.destroy(item.id).then((_) => {
    removeFromList(item)
  })
}

Note.where({
  note_object_id: props.objectId,
  note_object_type: props.objectType,
  per: 500
}).then(({ body }) => {
  list.value = body
})
</script>
