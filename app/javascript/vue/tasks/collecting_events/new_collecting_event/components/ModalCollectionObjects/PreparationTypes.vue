<template>
  <div>
    <h3>Preparation</h3>
    <div class="horizontal-left-content align-start">
      <ul
        v-for="(itemsGroup, index) in preparationGroups"
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
              :checked="type.id == preparationType"
              :value="type.id"
              v-model="preparationType"
              name="collection-object-type"
            />
            {{ type.name }}
          </label>
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup>
import { computed, onBeforeMount, ref } from 'vue'
import { PreparationType } from '@/routes/endpoints'

const preparationType = defineModel({
  type: [String, Number],
  default: undefined
})

const preparationTypes = ref([])

const preparationGroups = computed(() =>
  preparationTypes.value.chunk(Math.ceil(preparationTypes.value.length / 3))
)

onBeforeMount(async () => {
  preparationTypes.value = (await PreparationType.all()).body
  preparationTypes.value.push({
    id: undefined,
    name: 'None'
  })
})
</script>
