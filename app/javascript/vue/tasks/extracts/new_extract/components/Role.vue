<template>
  <block-layout>
    <template #header>
      <h3>By</h3>
    </template>
    <template #body>
      <div class="horizontal-left-content align-start">
        <smart-selector
          class="full_width"
          model="people"
          :params="{ role_type: 'SourceAuthor' }"
          :autocomplete-params="{
            roles: ['Extractor']
          }"
          label="cached"
          @selected="addRole"
        />
        <lock-component
          class="margin-small-left"
          v-model="settings.lock.roles"
        />
      </div>

      <role-picker
        class="margin-medium-top"
        role-type="Extractor"
        v-model="roles"
      />
    </template>
  </block-layout>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector.vue'
import componentExtend from './mixins/componentExtend'
import RolePicker from 'components/role_picker'
import BlockLayout from 'components/layout/BlockLayout'
import makePerson from 'factory/Person'
import LockComponent from 'components/ui/VLock/index.vue'
import { findRole } from 'helpers/people/people.js'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

export default {
  mixins: [componentExtend],

  components: {
    SmartSelector,
    RolePicker,
    BlockLayout,
    LockComponent
  },

  computed: {
    roles: {
      get () {
        return this.$store.getters[GetterNames.GetRoles]
      },
      set (value) {
        this.$store.commit(MutationNames.SetRoles, value)
      }
    }
  },

  methods: {
    addRole (role) {
      if (!findRole(this.roles, role.id)) {
        this.roles.push(
          makePerson(
            role.first_name,
            role.last_name,
            role.id,
            'Extractor'
          ))
      }
    }
  }
}
</script>
