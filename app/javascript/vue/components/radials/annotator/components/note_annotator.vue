<template>
  <div class="notes_annotator">
    <textarea class="separate-bottom" placeholder="Text..." v-model="note.text"/>
    <div v-if="note.hasOwnProperty('id')">
      <button type="button" class="button button-submit normal-input separate-bottom" @click="updateNote()" :disabled="!validateFields">Update</button>
      <button type="button" class="button button-default normal-input" @click="note = newNote()">New</button>
    </div>
    <div v-else>
      <button @click="createNew()" :disabled="!validateFields" class="button button-submit normal-input separate-bottom" type="button">Create</button>
    </div>
    <display-list label="text" :list="list" :edit="true" @edit="note = $event" @delete="removeItem" class="list"/>
  </div>
</template>
<script>

import CRUD from '../request/crud.js'
import annotatorExtend from '../components/annotatorExtend.js'
import autocomplete from 'components/ui/Autocomplete.vue'
import displayList from './displayList.vue'

export default {
  mixins: [CRUD, annotatorExtend],
  components: {
    displayList
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
        this.$set(this.list, this.list.findIndex(element => element.id == this.note.id), response.body)
        this.note = this.newNote()
      })
    }
  }
}
</script>
<style lang="scss">
.radial-annotator {
	.notes_annotator {
		button {
			min-width: 100px;
		}
		textarea {
			padding-top: 14px;
			padding-bottom: 14px;
			width: 100%;
			height: 100px;
		}
	}
}
</style>
