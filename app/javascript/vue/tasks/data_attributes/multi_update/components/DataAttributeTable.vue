<template>
  <table>
    <thead>
      <tr>
        <th>ID</th>
        <th>Object</th>
        <th
          v-for="item in store.predicates"
          :key="item.id"
        >
          {{ item.label }}
        </th>
        <th>
          <VBtn color="create">Save all</VBtn>
        </th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="(item, index) in list"
        :key="item.id"
      >
        <td>{{ item.id }}</td>
        <td>{{ item.label }}</td>
        <td></td>
        <td>
          <VBtn color="create"> Save </VBtn>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import useStore from '../store/store.js'
import VBtn from '@/components/ui/VBtn/index.vue'

const store = useStore()
</script>
