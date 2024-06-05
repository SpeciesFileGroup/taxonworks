<template>
  <div class="field">
    <label class="d-block">Type</label>
    <select v-model="type">
      <option
        v-for="item in types"
        :key="item.type"
        :value="item"
      >
        {{ item.name }}
      </option>
    </select>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Container } from '@/routes/endpoints'

const type = defineModel({
  type: Object,
  default: undefined
})

const types = ref([])

Container.types().then(({ body }) => {
  types.value = body
})
</script>
