<template>
  <div class="field label-above">
    <label>Preparation type</label>
    <select v-model="store.collectionObject.preparationTypeId">
      <option :value="undefined">
        None
      </option>
      <option
        v-for="(item, key) in preparationTypes"
        :key="key"
        :value="item.id"
      >
        {{ item.name }}
      </option>
    </select>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { PreparationType } from 'routes/endpoints'
import { useCollectionObjectStore } from '../../store/useCollectionObjectStore.js'

const store = useCollectionObjectStore()
const preparationTypes = ref([])

PreparationType.where({}).then(({ body }) => {
  preparationTypes.value = body
})
</script>
