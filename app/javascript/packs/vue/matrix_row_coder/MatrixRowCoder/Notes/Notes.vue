<template>
  <div class="notes">
    <div class="notes__header">Notes</div>
    <ul class="notes__list">
      <li
        class="notes__item"
        v-for="note in notes">

        {{ note.text }}
      </li>
    </ul>
  </div>
</template>

<style src="./Notes.styl" lang="stylus"></style>

<script>
export default {
  name: 'Notes',
  props: ['notes']
}
</script>
