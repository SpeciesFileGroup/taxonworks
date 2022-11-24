<template>
  <div>
    <div class="flex-separate middle">
      <span>Preparation type</span>
    </div>
    <div class="horizontal-left-content align-start">
      <select
        class="half_width"
        v-model="store.preparationTypeId"
      >
        <option :value="undefined">
          None
        </option>
        <option
          v-for="(item) in preparationTypes"
          :key="item.id"
          :value="item.id"
        >
          {{ item.name }}
        </option>
      </select>
      <VLock
        class="margin-small-left"
        v-model="store.settings.lock.preparationTypeId"
      />
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { PreparationType } from 'routes/endpoints'
import { useStore } from '../store/useStore.js'
import VLock from 'components/ui/VLock/index.vue'

const store = useStore()
const preparationTypes = ref([])

PreparationType.where({}).then(({ body }) => {
  preparationTypes.value = [
    ...body,
    {
      id: null,
      name: 'None'
    }
  ]
})

</script>
