<template>
  <BlockLayout>
    <template #header>
      <h3>{{ title }}</h3>
    </template>
    <template #body>
      <RolePicker
        v-model="roles_attributes"
        :role-type="roleType"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import { ref, watch } from 'vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import RolePicker from '@/components/role_picker'

const props = defineProps({
  title: {
    type: String,
    required: true
  },

  roleType: {
    type: String,
    required: true
  },

  modelValue: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const rolesAttributes = ref([])

watch(
  rolesAttributes,
  (newVal) => {
    emit('update:modelValue', newVal)
  },
  { deep: true }
)

watch(
  props.modelValue,
  (newVal) => {
    rolesAttributes.value = newVal
  },
  { deep: true }
)
</script>
