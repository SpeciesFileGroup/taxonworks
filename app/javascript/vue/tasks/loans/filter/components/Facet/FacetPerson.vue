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
          />
          {{ label }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>
<script setup>
import { ref, computed, watch, onBeforeMount } from 'vue'
import { People } from '@/routes/endpoints'
import { ROLE_LOAN_RECIPIENT, ROLE_LOAN_SUPERVISOR } from '@/constants/index.js'
import { addToArray, removeFromArray } from '@/helpers/arrays'
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

const people = ref([])
// Ids from the URL whose person couldn't be loaded (e.g. deleted). Kept in
// the filter, so it still matches what the URL asked for.
const unresolvedIds = ref([])
let hydrating = false

watch(
  people,
  (newVal) => {
    if (hydrating) return
    params.value.person_id = [
      ...newVal.map((p) => p.id),
      ...unresolvedIds.value
    ]
  },
  { deep: true }
)

watch(
  () => params.value.person_id,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      people.value = []
      unresolvedIds.value = []
    }
  }
)

onBeforeMount(async () => {
  // person_id holds ids (the watcher above stores ids; the URL gives ids).
  const ids = (params.value?.person_id || []).filter((id) => id != null)
  if (!ids.length) return

  // Load all of them before touching person_id, so a slow or failed lookup
  // can't drop ids from the filter in the meantime.
  hydrating = true
  const results = await Promise.allSettled(ids.map((id) => People.find(id)))
  const found = []
  const unresolved = []
  results.forEach((r, i) => {
    if (r.status === 'fulfilled') found.push(r.value.body)
    else unresolved.push(ids[i])
  })
  unresolvedIds.value = unresolved
  // Keep anyone picked while the lookups ran.
  people.value = [
    ...found,
    ...people.value.filter((p) => !found.some((f) => f.id === p.id))
  ]
  hydrating = false
})
</script>
