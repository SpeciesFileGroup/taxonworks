<template>
  <table class="table-striped full_width">
    <thead>
      <tr>
        <th class="w-2">ID</th>
        <th>Object</th>
        <th
          v-for="item in store.predicates"
          :key="item.id"
        >
          {{ item.label }}
        </th>
        <th class="w-2">
          <VBtn color="create">Save all</VBtn>
        </th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="item in store.objects"
        :key="item.id"
      >
        <td>{{ item.id }}</td>
        <td v-html="item.label" />
        <template
          v-for="predicate in store.predicates"
          :key="predicate.id"
        >
          <td>
            <input
              v-for="da in store.getDataAttributesByObject({
                objectType: item.type,
                objectId: item.id,
                predicateId: predicate.id
              })"
              :key="da.uuid"
              type="text"
              v-model="da.value"
              @change="() => (da.isUnsaved = true)"
            />
          </td>
        </template>
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
