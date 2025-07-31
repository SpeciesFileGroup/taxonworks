<template>
  <div>
    <table>
      <tr
        v-for="(row, index) in ROWS"
        :key="index"
      >
        <td
          v-for="letter in row"
          :key="letter"
          :class="{
            'selected-letter': letter == selected,
            'cursor-pointer': letter !== selected
          }"
          @click="sendLetter(letter)"
        >
          {{ letter }}
        </td>
      </tr>
    </table>
  </div>
</template>

<script setup>
import { setParam } from '@/helpers'

const ROWS = ['ABCDEFGHIJKLM'.split(''), 'NOPQRSTUVWXYZ'.split('')]

const selected = defineModel({
  type: String,
  required: true
})

function sendLetter(letter) {
  if (letter == selected.value) return
  setSelectedLetter(letter)
}

function setSelectedLetter(letter) {
  selected.value = letter
  setParam('/tasks/people/author', 'letter', letter)
}
</script>

<style scoped>
.selected-letter {
  color: #fff;
  background-color: #e3e8e3;
}
</style>
