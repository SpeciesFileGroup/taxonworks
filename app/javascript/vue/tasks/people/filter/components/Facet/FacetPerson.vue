<template>
  <div class="field">
    <label class="display-block">First name</label>
    <input
      type="text"
      v-model="fields.first_name"
    >
    <label>
      <input 
        type="checkbox"
        value="first_name"
        v-model="fields.exact"
      >
      Exact
    </label>
  </div>
  <div class="field">
    <label class="display-block">Last name</label>
    <input
      type="text"
      v-model="fields.last_name"
    >
    <label>
      <input 
        type="checkbox"
        value="last_name"
        v-model="fields.exact"
      >
      Exact
    </label>
  </div>
  <div class="field">
    <label class="display-block">Suffix</label>
    <input 
      type="text"
      v-model="fields.suffix"
    >
    <label>
      <input 
        type="checkbox"
        value="suffix"
        v-model="fields.exact"
      >
      Exact
    </label>
  </div>
  <div class="field">
    <label class="display-block">Prefix</label>
    <input 
      type="text"
      v-model="fields.prefix"
    >
    <label>
      <input 
        type="checkbox"
        value="prefix"
        v-model="fields.exact"
      >
      Exact
    </label>
  </div>
</template>

<script setup>
import { computed } from 'vue';

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const emit = defineEmits('update:modelValue')

const fields = computed({
  get () {
    return props.modelValue
  },

  set (value) {
    emit('update:modelValue', value)
  }
})

</script>