<template>
  <PeopleSelector
    v-model="editors"
    :role-type="ROLE_ATTRIBUTION_EDITOR"
    title="Editor"
  />
</template>

<script setup>
import { ROLE_ATTRIBUTION_EDITOR } from '@/constants'
import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'
import { computed } from 'vue'
import { useStore } from 'vuex'
import PeopleSelector from '../PeopleSelector.vue'

const store = useStore()

const editors = computed({
  get: () => store.getters[GetterNames.GetPeople].editors,

  set(value) {
    store.commit(MutationNames.SetEditors, value)
  }
})
</script>
