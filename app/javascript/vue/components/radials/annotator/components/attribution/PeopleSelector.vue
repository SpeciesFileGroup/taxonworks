<template>
  <VSwitch
    v-if="organization"
    class="separate-bottom"
    :full-width="switchFullWidth"
    :options="Object.values(OPTIONS)"
    v-model="view"
  />
  <RolePicker
    v-model="rolesAttributes"
    :role-type="roleType"
    :organization="view === OPTIONS.Organization"
    :show-create-controls="showCreateControls"
    :autofocus="autofocus"
  />
</template>

<script setup>
import { ref, computed } from 'vue'
import RolePicker from '@/components/role_picker.vue'
import VSwitch from '@/components/ui/VSwitch.vue'

const OPTIONS = {
  People: 'People',
  Organization: 'An organization'
}

const props = defineProps({
  roleType: {
    type: String,
    required: true
  },

  modelValue: {
    type: Array,
    required: true
  },

  organization: {
    type: Boolean,
    default: false
  },

  showCreateControls: {
    type: Boolean,
    default: true
  },

  autofocus: {
    type: Boolean,
    default: true
  },

  switchFullWidth: {
    type: Boolean,
    default: true
  }
})

const emit = defineEmits(['update:modelValue'])

const view = ref(OPTIONS.People)

const rolesAttributes = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})
</script>
