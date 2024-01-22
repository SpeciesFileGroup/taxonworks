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
import { addToArray, removeFromArray } from '@/helpers'
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
  }
})

const emit = defineEmits(['update-count'])

const validateFields = computed(() => note.value.text)

const list = ref([])
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
    addToArray(list.value, body)
    emit('update-count', list.value.length)
  })
}

function removeItem(item) {
  Note.destroy(item.id).then((_) => {
    removeFromArray(list.value, item)
    emit('update-count', list.value.length)
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
