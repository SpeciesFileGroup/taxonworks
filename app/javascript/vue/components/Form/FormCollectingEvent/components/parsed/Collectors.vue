<template>
  <fieldset>
    <legend>Collectors</legend>
    <smart-selector
      ref="smartSelector"
      model="people"
      target="Collector"
      klass="CollectingEvent"
      :params="{ role_type: 'Collector' }"
      :autocomplete-params="{
        roles: ['Collector']
      }"
      label="cached"
      :autocomplete="false"
      @selected="addRole"
    >
      <template #header>
        <role-picker
          hidden-list
          v-model="collectingEvent.roles_attributes"
          ref="rolepickerRef"
          :autofocus="false"
          role-type="Collector"
        />
      </template>
      <role-picker
        :create-form="false"
        v-model="collectingEvent.roles_attributes"
        :autofocus="false"
        role-type="Collector"
      />
    </smart-selector>
  </fieldset>
</template>

<script setup>
import { ref } from 'vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import RolePicker from '@/components/role_picker.vue'

const collectingEvent = defineModel()
const rolepickerRef = ref(null)

function addRole(role) {
  rolepickerRef.value.addPerson(role)
}
</script>
