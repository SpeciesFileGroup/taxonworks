<template>
  <PeopleSelector
    v-model="owners"
    :role-type="ROLE_ATTRIBUTION_OWNER"
    title="Owner"
  />
</template>

<script setup>
import { ROLE_ATTRIBUTION_OWNER } from '@/constants'
import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'
import { computed } from 'vue'
import { useStore } from 'vuex'
import PeopleSelector from '../PeopleSelector.vue'

const store = useStore()

const owners = computed({
  get: () => store.getters[GetterNames.GetPeople].owners,

  set(value) {
    store.commit(MutationNames.SetOwners, value)
  }
})
</script>
