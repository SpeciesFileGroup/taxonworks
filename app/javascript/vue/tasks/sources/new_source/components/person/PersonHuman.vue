<template>
  <SmartSelector
    v-help.section.BibTeX.authors
    model="people"
    :target="ROLE_SOURCE_SOURCE"
    :klass="SOURCE"
    label="cached"
    :params="{ role_type: ROLE_SOURCE_SOURCE }"
    :autocomplete-params="{
      roles: [ROLE_SOURCE_SOURCE]
    }"
    :filter-ids="peopleIds"
    :autocomplete="false"
    @selected="addRole"
    @on-tab-selected="view = $event"
  >
    <template #header>
      <RolePicker
        ref="rolePicker"
        v-model="store.source.roles_attributes"
        :autofocus="false"
        hidden-list
        filter-by-role
        :role-type="ROLE_SOURCE_SOURCE"
      />
    </template>
    <RolePicker
      v-model="store.source.roles_attributes"
      :role-type="ROLE_SOURCE_SOURCE"
      :create-form="false"
      :autofocus="false"
      filter-by-role
    />
  </SmartSelector>
</template>

<script setup>
import { ROLE_SOURCE_SOURCE, SOURCE } from '@/constants'
import { computed, ref } from 'vue'
import { useSourceStore } from '../../store'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import RolePicker from '@/components/role_picker.vue'

const store = useSourceStore()
const rolePicker = ref(null)

const peopleIds = computed(() => {
  return store.source.roles_attributes
    .filter((item) => item.person_id || item.person)
    .map((item) => item?.person_id || item.person.id)
})

function addRole(person) {
  rolePicker.value.addPerson(person)
}
</script>

<style scoped>
textarea {
  width: 100%;
  height: 100px;
}
</style>
