<template>
  <BlockLayout>
    <template #header>
      <h3>{{ title }}</h3>
    </template>
    <template #body>
      <div class="margin-large-bottom">
        <VSwitch
          v-if="organization"
          class="separate-bottom"
          full-width
          :options="Object.values(OPTIONS)"
          v-model="view"
        />
        <RolePicker
          v-model="rolesAttributes"
          :role-type="roleType"
          :organization="view === OPTIONS.Organization"
        />
      </div>
    </template>
  </BlockLayout>
</template>

<script setup>
import { ref, computed } from 'vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import RolePicker from '@/components/role_picker'
import VSwitch from '@/components/switch.vue'

const OPTIONS = {
  People: 'Someone else',
  Organization: 'An organization'
}

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
  },

  organization: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:modelValue'])

const view = ref(OPTIONS.People)

const rolesAttributes = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})
</script>
