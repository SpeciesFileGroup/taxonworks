<template>
  <fieldset v-help.section.BibTeX.authors>
    <legend>Authors</legend>
    <smart-selector
      model="people"
      :target="ROLE_SOURCE_AUTHOR"
      :klass="SOURCE"
      label="cached"
      :params="{ role_type: ROLE_SOURCE_AUTHOR }"
      :autocomplete-params="{
        roles: [ROLE_SOURCE_AUTHOR]
      }"
      :filter-ids="peopleIds"
      :autocomplete="false"
      @selected="addRole"
    >
      <template #header>
        <RolePicker
          ref="rolePicker"
          v-model="roleAttributes"
          :autofocus="false"
          :hidden-list="true"
          :filter-by-role="true"
          :role-type="ROLE_SOURCE_AUTHOR"
        />
      </template>
      <RolePicker
        v-model="roleAttributes"
        :create-form="false"
        :autofocus="false"
        :filter-by-role="true"
        :role-type="ROLE_SOURCE_AUTHOR"
      />
    </smart-selector>
  </fieldset>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useStore } from 'vuex'
import { ROLE_SOURCE_AUTHOR, SOURCE } from '@/constants'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import RolePicker from '@/components/role_picker.vue'

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
        item.type === ROLE_SOURCE_AUTHOR
    )
    .map((item) => item?.person_id || item.person.id)
)

function addRole(person) {
  rolePicker.value.addPerson(person)
}
</script>
