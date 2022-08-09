<template>
  <fieldset>
    <legend>Determiner</legend>
    <div class="horizontal-left-content margin-small-bottom">
      <VSwitch
        class="full_width"
        v-model="roleView"
        :options="Object.values(ROLE_TABS)"
      />
      <v-lock
        v-if="lock !== undefined"
        class="margin-small-left"
        v-model="lockButton"
      />
    </div>
    <div class="horizontal-left-content separate-bottom align-start">
      <smart-selector
        class="full_width"
        model="people"
        target="Determiner"
        label="cached"
        :autocomplete="false"
        @selected="addPerson"
      >
        <template #header>
          <role-picker
            class="role-picker"
            :autofocus="false"
            role-type="Determiner"
            :organization="roleView === ROLE_TABS.organization"
            v-model="roles"
          />
        </template>
      </smart-selector>
    </div>
  </fieldset>
</template>

<script setup>

import { computed, ref } from 'vue'
import { ROLE_DETERMINER } from 'constants/index.js'
import { findRole } from 'helpers/people/people.js'
import makePerson from 'factory/Person'
import makeTaxonDetermination from 'factory/TaxonDetermination.js'
import SmartSelector from 'components/ui/SmartSelector.vue'
import RolePicker from 'components/role_picker.vue'
import VLock from 'components/ui/VLock/index.vue'
import VSwitch from 'components/switch.vue'

const props = defineProps({
  modelValue: {
    type: Array,
    default: () => makeTaxonDetermination()
  },

  lock: {
    type: Boolean,
    default: undefined
  }
})

const ROLE_TABS = {
  people: 'People',
  organization: 'Organization'
}

const emit = defineEmits([
  'update:modelValue',
  'update:lock'
])

const roleView = ref(ROLE_TABS.people)

const lockButton = computed({
  get: () => props.lock,
  set: value => emit('update:lock', value)
})

const roles = computed({
  get: () => props.modelValue,
  set (value) {
    emit('update:modelValue', value)
  }
})

const addPerson = role => {
  if (!findRole(roles.value, role.id)) {
    roles.value.push(
      makePerson(
        role.first_name,
        role.last_name,
        role.id,
        ROLE_DETERMINER
      )
    )
  }
}

</script>
