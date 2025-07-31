import { defineStore } from 'pinia'

export default defineStore('notes', {
  state: () => ({
    text: '',
    notes: []
  }),

  actions: {
    addNote() {
      this.notes.push(this.text)
      this.text = ''
    },

    removeNote(note) {
      this.notes = this.notes.filter((value) => value === note)
    }
  }
})
