<template>
  <div class="flex-separate">
    <role-picker
      v-model="roles"
      role-type="TaxonNameAuthor"
    />
  </div>
</template>
<script setup>

import { computed } from 'vue'
import RolePicker from 'components/role_picker.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})
const emit = defineEmits(['update:modelValue'])

const combination = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const roles = computed({
  get () {
    const roles = combination.value.roles_attributes

    return roles
      ? roles.sort((a, b) => a.position - b.position)
      : []
  },
  set (value) {
    combination.value.roles_attributes = value
  }
})

</script>
