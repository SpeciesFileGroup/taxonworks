<template>
  <div class="field">
    <label class="d-block">Type</label>
    <select
      class="capitalize"
      v-model="container.type"
      @change="setType"
    >
      <option
        v-for="item in types"
        :key="item.type"
        :value="item.type"
      >
        {{ item.name }}
      </option>
    </select>
  </div>
</template>

<script setup>
const props = defineProps({
  types: {
    type: Array,
    required: true
  }
})
const container = defineModel({
  type: Object,
  required: true
})

function setType(e) {
  const type = e.target.value
  const { dimensions } = props.types.find((item) => item.type === type)

  container.value.type = type
  container.value.size = {
    x: 1,
    y: 1,
    z: 1,
    ...dimensions
  }
}
</script>
