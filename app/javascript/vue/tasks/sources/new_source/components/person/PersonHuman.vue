<template>
  <fieldset v-help.section.BibTeX.authors>
    <legend>People</legend>
    <SmartSelector
      model="people"
      :target="ROLE_SOURCE_SOURCE"
      klass="Source"
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
          v-model="roles"
          :autofocus="false"
          hidden-list
          filter-by-role
          :role-type="ROLE_SOURCE_SOURCE"
        />
      </template>
      <RolePicker
        v-model="roles"
        :role-type="ROLE_SOURCE_SOURCE"
        :create-form="false"
        :autofocus="false"
        filter-by-role
      />
    </SmartSelector>
  </fieldset>
</template>

<script setup>
import { ROLE_SOURCE_SOURCE } from '@/constants'
import { computed, ref } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import { findRole } from '@/helpers/people/people.js'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import RolePicker from '@/components/role_picker.vue'

const store = useStore()
const rolePicker = ref(null)

const roles = computed({
  get() {
    return store.getters[GetterNames.GetRoleAttributes]
  },
  set(value) {
    store.commit(MutationNames.SetRoles, value)
  }
})

const peopleIds = computed(() => {
  return roles.value
    .filter((item) => item.person_id || item.person)
    .map((item) => item?.person_id || item.person.id)
})

function addRole(person) {
  if (!findRole(roles.value, person.id)) {
    rolePicker.value.setPerson(person)
  }
}
</script>

<style scoped>
textarea {
  width: 100%;
  height: 100px;
}
</style>
