<template>
  <div v-if="types.length == 1">
    <h3>Change namespace of {{ Object.keys(types[0])[0] }}</h3>
  </div>

  <div v-else>
    <h3>Change namespace of:</h3>

    <ul class="no_bullets">
      <li
        v-for="type in types"
        :key="type['klass']"
      >
        <label>
          <input
            type="checkbox"
            :value="type['klass']"
            v-model="identifierType"
          />
          {{ type['display'] }}
        </label>
      </li>
    </ul>
  </div>

</template>

<script setup>
import { ref } from 'vue'
const a = ref(null)
const props = defineProps({
  types: {
    type: Array,
    required: true
  }
})

const identifierType = defineModel({
  type: Array,
  required: true
})
</script>
