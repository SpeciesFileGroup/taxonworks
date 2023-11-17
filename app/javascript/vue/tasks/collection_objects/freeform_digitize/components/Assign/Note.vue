<template>
  <fieldset>
    <legend>Note</legend>
    <div class="align-start">
      <textarea
        v-model="store.text"
        class="full_width margin-small-right"
        rows="5"
      >
      </textarea>
      <VLock v-model="lock.notes_attributes" />
    </div>
    <button
      @click="addNote"
      :disabled="!store.text"
      class="button normal-input button-submit"
    >
      Add
    </button>
    <list-component
      v-if="store.notes.length"
      :list="store.notes"
      @delete="removeNote"
      :label="[]"
    />
  </fieldset>
</template>

<script setup>
import ListComponent from '@/components/displayList'
import VLock from '@/components/ui/VLock/index.vue'
import useStore from '../../store/notes'
import useLockStore from '../../store/lock.js'

const store = useStore()
const lock = useLockStore()

function addNote() {
  store.notes.push(store.text)
  store.text = ''
}

function removeNote(note) {
  store.notes = store.notes.filter((value) => value === note)
}
</script>
