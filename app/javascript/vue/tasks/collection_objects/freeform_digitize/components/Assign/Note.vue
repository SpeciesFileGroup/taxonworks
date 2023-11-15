<template>
  <fieldset>
    <legend>Note</legend>
    <div class="align-start">
      <textarea
        v-model="text"
        class="full_width margin-small-right"
        rows="5"
      >
      </textarea>
      <lock-component v-model="lock.notes_attributes" />
    </div>
    <button
      @click="addNote"
      :disabled="!text"
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
import { ref } from 'vue'
import ListComponent from '@/components/displayList'
import useStore from '../../store/store'
import useLockStore from '../../store/lock.js'

const store = useStore()
const lock = useLockStore()
const text = ref('')

function addNote() {
  store.notes.push(text.value)
  text.value = ''
}

function removeNote(note) {
  store.notes = store.notes.filter((value) => value === note)
}
</script>
