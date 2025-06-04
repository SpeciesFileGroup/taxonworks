<template>
  <div v-if="types.length == 1">
    <h3>Change namespace of {{ types[0]['display'] }}</h3>
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
