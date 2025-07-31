<template>
  <div class="field">
    <label class="d-block">Model</label>
    <select v-model="modelSelected">
      <option
        :value="null"
        disabled
      >
        None
      </option>
      <option
        v-for="model in models"
        :key="model"
        :value="model"
      >
        {{ model }}
      </option>
    </select>
  </div>
</template>

<script setup>
import { TYPE_LINKS } from '../constants/types.js'

const models = Object.keys(TYPE_LINKS)
const modelSelected = defineModel({
  type: String,
  default: null
})
</script>
