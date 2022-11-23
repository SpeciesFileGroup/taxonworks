<template>
  <div class="panel content">
    <div class="flex-separate middle">
      <h2>Preparation</h2>
      <VLock v-model="store.settings.lock.preparationTypeId" />
    </div>
    <div class="horizontal-left-content align-start">
      <ul
        v-for="(itemsGroup, index) in chunkList"
        :key="index"
        class="no_bullets full_width"
      >
        <li
          v-for="preparationType in itemsGroup"
          :key="preparationType.id"
        >
          <label>
            <input
              type="radio"
              :value="preparationType.id"
              v-model="store.preparationTypeId"
              name="collection-object-type"
            >
            {{ preparationType.name }}
          </label>
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
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

const chunkList = computed(() =>
  preparationTypes.value.chunk(Math.ceil(preparationTypes.value.length / 3))
)

</script>
