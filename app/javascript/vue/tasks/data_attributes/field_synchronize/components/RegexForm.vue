<template>
  <div class="horizontal-left-content gap-medium">
    <div>
      <label> From </label>
      <select v-model="to">
        <option
          :value="undefined"
          disabled
          selected
        >
          Select...
        </option>
        <option
          v-for="attribute in attributes"
          :key="attribute"
        >
          {{ attribute }}
        </option>
      </select>
    </div>

    <div>
      <label class="d-block">Find</label>
      <input
        type="text"
        v-model="regex"
      />
      <label class="d-block">Replace</label>
      <input type="text" />
    </div>

    <div>
      <label>To</label>
      <select v-model="from">
        <option
          :value="undefined"
          disabled
          selected
        >
          Select...
        </option>
        <option
          v-for="attribute in attributes"
          :key="attribute"
        >
          {{ attribute }}
        </option>
      </select>
    </div>
  </div>
</template>

<script setup>
defineProps({
  attributes: {
    type: Array,
    default: () => []
  }
})

const to = defineModel('to', {
  type: String,
  default: undefined
})

const from = defineModel('from', {
  type: String,
  default: undefined
})

const regex = defineModel({
  type: String,
  default: ''
})
</script>
