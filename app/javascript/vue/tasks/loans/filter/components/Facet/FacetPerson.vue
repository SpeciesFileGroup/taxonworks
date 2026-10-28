<template>
  <FacetContainer>
    <h3>Person (Recipient/Supervisor)</h3>
    <SmartSelector
      model="people"
      @selected="add"
    />
    <DisplayList
      v-if="people.length"
      label="object_tag"
      soft-delete
      :warning="false"
      :list="people"
      @delete-index="remove"
    />

    <p>
      <b>Role</b>
    </p>
    <ul class="no_bullets">
      <li
        v-for="(role, label) in ROLE"
        :key="role"
      >
        <label>
          <input
            :value="role"
            type="radio"
            v-model="selectedRoles"
          />
          {{ label }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>
<script setup>
import { computed, onBeforeMount } from 'vue'
import { People } from '@/routes/endpoints'
import { ROLE_LOAN_RECIPIENT, ROLE_LOAN_SUPERVISOR } from '@/constants/index.js'
import { useHydratedFacetList, missingRecord } from '@/components/Filter/composables/useHydratedFacetList.js'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import DisplayList from '@/components/displayList.vue'

const ROLE = {
  Recipient: ROLE_LOAN_RECIPIENT,
  Supervisor: ROLE_LOAN_SUPERVISOR
}

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const selectedRoles = computed({
  get: () => params.value.role || [],
  set: (value) => {
    params.value.role = value
  }
})

const {
  list: people,
  hydrate,
  add,
  remove
} = useHydratedFacetList({
  ids: () => params.value.person_id,
  write: (items) => {
    params.value.person_id = items.map((item) => item.id)
  },
  load: (id) => People.find(id).then(({ body }) => body),
  missing: missingRecord
})

onBeforeMount(() => {
  hydrate(params.value?.person_id)
})
</script>
