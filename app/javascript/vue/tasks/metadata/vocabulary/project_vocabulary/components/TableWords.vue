<template>
  <table class="table-striped">
    <thead>
      <tr>
        <th @click="sortList(0)">Term</th>
        <th @click="sortList(1)">Count</th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="[term, count] in list"
        :key="term"
        @click="emit('select', term)"
      >
        <td v-text="term" />
        <td v-text="count" />
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import { ref } from 'vue'
import { sortArray } from '@/helpers'

const list = defineModel({
  type: Array,
  default: () => []
})

const emit = defineEmits(['select', 'sort'])

const asc = ref(true)

function sortList(position) {
  list.value = sortArray(list.value, position, asc.value)
  asc.value = !asc.value
}
</script>
