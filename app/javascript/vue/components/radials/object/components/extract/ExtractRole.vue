<template>
  <fieldset>
    <legend>By</legend>
    <SmartSelector
      class="full_width"
      model="people"
      :params="{ role_type: ROLE_EXTRACTOR }"
      :autocomplete="false"
      label="cached"
      @selected="addRole"
    >
      <template #header>
        <RolePicker
          v-model="roles"
          :autofocus="false"
          :hidden-list="true"
          :filter-by-role="true"
          :role-type="ROLE_EXTRACTOR"
        />
      </template>
      <RolePicker
        v-model="roles"
        :create-form="false"
        :autofocus="false"
        :filter-by-role="true"
        :role-type="ROLE_EXTRACTOR"
      />
    </SmartSelector>
  </fieldset>
</template>

<script setup>
import SmartSelector from '@/components/ui/SmartSelector.vue'
import RolePicker from '@/components/role_picker'
import makePerson from '@/factory/Person'
import { findRole } from '@/helpers/people/people.js'
import { ROLE_EXTRACTOR } from '@/constants'

const roles = defineModel({
  type: Object,
  required: true
})

function addRole(role) {
  if (!findRole(roles.value, role.id)) {
    roles.value.push(
      makePerson(role.first_name, role.last_name, role.id, ROLE_EXTRACTOR)
    )
  }
}
</script>
