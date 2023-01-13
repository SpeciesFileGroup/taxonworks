<template>
  <FacetContainer>
    <h3>Person (Recipient/Supervisor)</h3>
    <SmartSelector
      model="people"
      @selected="addToArray(people, $event)"
    />
    <DisplayList
      v-if="people.length"
      label="object_tag"
      soft-delete
      :warning="false"
      :list="people"
      @delete="removeFromArray(people, $event)"
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
          >
          {{ label }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>
<script setup>
import { ref, computed, watch, onBeforeMount } from 'vue'
import { People } from 'routes/endpoints'
import {
  ROLE_LOAN_RECIPIENT,
  ROLE_LOAN_SUPERVISOR
} from 'constants/index.js'
import {
  addToArray,
  removeFromArray
} from 'helpers/arrays'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import SmartSelector from 'components/ui/SmartSelector.vue'
import DisplayList from 'components/displayList.vue'

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
  set: value => emit('update:modelValue', value)
})

const selectedRoles = computed({
  get: () => params.value.role || [],
  set: value => { params.value.role = value }
})

const people = ref([])

watch(
  people,
  newVal => {
    params.value.person_id = newVal.map(p => p.id)
  },
  { deep: true }
)

watch(
  () => params.value.person_id,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      people.value = []
    }
  }
)

onBeforeMount(() => {
  const ids = params.value?.person_id?.map(p => p.id) || []

  ids.forEach(id => {
    People.find(id).then(({ body }) => {
      addToArray(people, body)
    })
  })
})

</script>
