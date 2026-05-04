<template>
  <div>
    <VSpinner v-if="isLoading" />
    <h3>Preparation</h3>
    <div
      v-if="preparationTypes.length > 0"
    >
      <div
        v-if="display === 'radio'"
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

      <select
        v-else
        v-model="anatomicalPart.preparation_type_id"
        class="normal-input"
      >
        <option
          v-for="type in preparationTypes"
          :key="type.id"
          :value="type.id"
        >
          {{ type.name }}
        </option>
      </select>
    </div>

    <div v-else>
      <i>No preparation types are defined.</i>
    </div>
  </div>
</template>

<script setup>
import VSpinner from '@/components/ui/VSpinner.vue'
import { PreparationType } from '@/routes/endpoints'
import { computed, onMounted, ref } from 'vue'

const anatomicalPart = defineModel({
  type: Object,
  required: true
})

defineProps({
  display: {
    type: String,
    default: 'radio',
    validator: (value) => ['radio', 'select'].includes(value)
  }
})

const preparationTypes = ref([])
const isLoading = ref(false)

const chunkList = computed(() => {
  return preparationTypes.value.chunk(Math.ceil(preparationTypes.value.length / 5))
})

onMounted(() => {
  isLoading.value = true
  PreparationType.all()
    .then(({ body }) => {
      preparationTypes.value = body
      preparationTypes.value.unshift({
        id: null,
        name: 'None'
      })
    })
    .catch(() => {})
    .finally(() => (isLoading.value = false))
})
</script>

<style scoped>
.preparation-list {
  width: 100%;
}
</style>
