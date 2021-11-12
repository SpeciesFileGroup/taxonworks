<template>
  <fieldset>
    <legend>Determiner</legend>
    <div class="horizontal-left-content separate-bottom align-start">
      <smart-selector
        class="full_width"
        ref="determinerSmartSelector"
        model="people"
        target="Determiner"
        label="cached"
        :autocomplete="false"
        @selected="addRole">
        <template #header>
          <role-picker
            class="role-picker"
            :autofocus="false"
            hidden-list
            ref="rolepicker"
            role-type="Determiner"
            v-model="roles"/>
        </template>
        <role-picker
          class="role-picker"
          :autofocus="false"
          :create-form="false"
          role-type="Determiner"
          v-model="roles"
        />
      </smart-selector>
    </div>
  </fieldset>
</template>

<script setup>

import { computed } from 'vue'
import { ROLE_DETERMINER } from 'constants/index.js'
import { findRole } from 'helpers/people/people.js'
import makePerson from 'factory/Person'
import makeTaxonDetermination from 'factory/TaxonDetermination.js'
import SmartSelector from 'components/ui/SmartSelector.vue'
import RolePicker from 'components/role_picker.vue'

const props = defineProps({
  modelValue: {
    type: Array,
    default: () => makeTaxonDetermination()
  }
})

const emit = defineEmits([
  'update:modelValue'
])

const roles = computed({
  get: () => props.modelValue,

  set (value) {
    emit('update:modelValue', value)
  }
})

const addRole = role => {
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
