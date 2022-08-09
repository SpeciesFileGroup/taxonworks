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
        @click="updateNote()">
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
        @click="createNew()"
      >
        Create
      </v-btn>
    </div>
    <display-list 
      label="text" 
      :list="list" 
      edit 
      @edit="note = $event" 
      @delete="removeItem" 
    />
  </div>
</template>
<script>

import CRUD from '../request/crud.js'
import annotatorExtend from '../components/annotatorExtend.js'
import DisplayList from 'components/displayList.vue'
import VBtn from 'components/ui/VBtn/index.vue'

export default {
  mixins: [CRUD, annotatorExtend],
  components: {
    DisplayList,
    VBtn
  },
  computed: {
    validateFields () {
      return this.note.text
    }
  },
  data: function () {
    return {
      list: [],
      note: this.newNote()
    }
  },
  methods: {
    newNote () {
      return {
        text: null,
        annotated_global_entity: decodeURIComponent(this.globalId)
      }
    },
    createNew () {
      this.create('/notes', { note: this.note }).then(response => {
        this.list.push(response.body)
        this.note = this.newNote()
      })
    },
    updateNote () {
      this.update(`/notes/${this.note.id}`, { note: this.note }).then(response => {
        const index = this.list.findIndex(element => element.id === this.note.id)

        this.list[index] = response.body
        this.note = this.newNote()
      })
    }
  }
}
</script>

