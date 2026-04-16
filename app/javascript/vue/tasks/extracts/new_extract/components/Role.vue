<template>
  <block-layout>
    <template #header>
      <h3>By</h3>
    </template>
    <template #body>
      <div class="horizontal-left-content align-start">
        <SmartSelector
          class="full_width"
          model="people"
          :params="{ role_type: ROLE_EXTRACTOR }"
          :autocomplete-params="{
            roles: [ROLE_EXTRACTOR]
          }"
          label="cached"
          @selected="addRole"
        />
        <LockComponent
          class="margin-small-left"
          v-model="settings.lock.roles"
        />
      </div>

      <RolePicker
        class="margin-medium-top"
        :role-type="ROLE_EXTRACTOR"
        v-model="roles"
      />
    </template>
  </block-layout>
</template>

<script setup>
import SmartSelector from '@/components/ui/SmartSelector.vue'
import RolePicker from '@/components/role_picker'
import BlockLayout from '@/components/layout/BlockLayout'
import makePerson from '@/factory/Person'
import LockComponent from '@/components/ui/VLock/index.vue'
import { findRole } from '@/helpers/people/people.js'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { computed } from 'vue'
import { useStore } from 'vuex'
import { ROLE_EXTRACTOR } from '@/constants'

const store = useStore()
const roles = computed({
  get: () => store.getters[GetterNames.GetRoles],
  set: (value) => store.commit(MutationNames.SetRoles, value)
})

const settings = computed({
  get: () => store.getters[GetterNames.GetSettings],
  set: (value) => store.commit(MutationNames.SetSettings, value)
})

function addRole(role) {
  if (!findRole(roles.value, role.id)) {
    roles.value.push(
      makePerson(role.first_name, role.last_name, role.id, ROLE_EXTRACTOR)
    )
  }
}
</script>
