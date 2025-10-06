<template>
  <div>
    <h3>Preparation</h3>
    <div
      v-if="preparationTypes.length > 0"
      class="horizontal-left-content align-start"
    >
      <ul
        v-for="(itemsGroup, index) in chunkList"
        :key="index"
        class="no_bullets preparation-list"
      >
        <li
          v-for="type in itemsGroup"
          :key="type.id"
        >
          <label>
            <input
              type="radio"
              :value="type.id"
              v-model="anatomicalPart.preparation_type_id"
              name="anatomical-part-preparation-type"
            />
            {{ type.name }}
          </label>
        </li>
      </ul>
    </div>

    <div v-else>
      <i>No preparation types are defined.</i>
    </div>
  </div>
</template>

<script setup>
import { PreparationType } from '@/routes/endpoints'
import { computed, onMounted, ref } from 'vue'

const anatomicalPart = defineModel({
  type: Object,
  required: true
})

const preparationTypes = ref([])

const chunkList = computed(() => {
  return preparationTypes.value.chunk(Math.ceil(preparationTypes.value.length / 5))
})

onMounted(() => {
  PreparationType.all()
    .then(({ body }) => {
      preparationTypes.value = body
      preparationTypes.value.unshift({
        id: null,
        name: 'None'
      })
    })
    .catch(() => {})
})
</script>

<style scoped>
.preparation-list {
  width: 100%;
}
</style>
