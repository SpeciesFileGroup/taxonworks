<template>
  <fieldset v-help.section.BibTeX.editors>
    <legend>Editors</legend>
    <smart-selector
      model="people"
      label="cached"
      :target="ROLE_SOURCE_EDITOR"
      :klass="SOURCE"
      :filter-ids="peopleIds"
      :params="{ role_type: ROLE_SOURCE_EDITOR }"
      :autocomplete-params="{
        roles: [ROLE_SOURCE_EDITOR]
      }"
      :autocomplete="false"
      @selected="addRole"
    >
      <template #header>
        <RolePicker
          v-model="roleAttributes"
          ref="rolePicker"
          filter-by-role
          hidden-list
          :autofocus="false"
          :role-type="ROLE_SOURCE_EDITOR"
        />
      </template>
      <RolePicker
        v-model="roleAttributes"
        :create-form="false"
        :autofocus="false"
        filter-by-role
        :role-type="ROLE_SOURCE_EDITOR"
      />
    </smart-selector>
  </fieldset>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import { ROLE_SOURCE_EDITOR, SOURCE } from '@/constants'
import RolePicker from '@/components/role_picker.vue'
import SmartSelector from '@/components/ui/SmartSelector'

const store = useStore()
const rolePicker = ref(null)

const roleAttributes = computed({
  get() {
    return store.getters[GetterNames.GetRoleAttributes]
  },
  set(value) {
    store.commit(MutationNames.SetRoles, value)
  }
})

const peopleIds = computed(() =>
  roleAttributes.value
    .filter(
      (item) =>
        (item.person_id || item.person) &&
        !item._destroy &&
        item.type === ROLE_SOURCE_EDITOR
    )
    .map((item) => item?.person_id || item.person.id)
)

function addRole(person) {
  rolePicker.value.addPerson(person)
}
</script>
