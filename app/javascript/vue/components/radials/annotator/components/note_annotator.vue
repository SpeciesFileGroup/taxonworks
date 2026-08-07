<template>
  <div class="notes_annotator">
    <textarea
      class="separate-bottom"
      v-model="note.text"
      rows="10"
      placeholder="Text..."
    />
    <div v-if="note.id">
      <v-btn
        class="margin-small-right"
        color="create"
        medium
        :disabled="!validateFields"
        @click="saveNote()"
      >
        Update
      </v-btn>
      <v-btn
        color="primary"
        medium
        @click="note = newNote()"
      >
        New
      </v-btn>
    </div>
    <div v-else>
      <v-btn
        medium
        color="create"
        :disabled="!validateFields"
        @click="saveNote()"
      >
        Create
      </v-btn>
    </div>
    <display-list
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
