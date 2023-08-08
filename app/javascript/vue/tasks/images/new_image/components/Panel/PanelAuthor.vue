<template>
  <PeopleSelector
    v-model="authors"
    :role-type="ROLE_ATTRIBUTION_CREATOR"
    title="Author/Creator"
  />
</template>

<script setup>
import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'
import { computed } from 'vue'
import { useStore } from 'vuex'
import { ROLE_ATTRIBUTION_CREATOR } from '@/constants'
import PeopleSelector from '../PeopleSelector.vue'

const store = useStore()

const authors = computed({
  get: () => store.getters[GetterNames.GetPeople].authors,

  set(value) {
    store.commit(MutationNames.SetAuthors, value)
  }
})
</script>
