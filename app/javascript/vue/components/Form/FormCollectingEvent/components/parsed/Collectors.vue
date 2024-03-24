<template>
  <fieldset>
    <legend>Collectors</legend>
    <SmartSelector
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
        <RolePicker
          hidden-list
          v-model="collectingEvent.roles_attributes"
          ref="rolepickerRef"
          :autofocus="false"
          role-type="Collector"
          @update:model-value="() => (collectingEvent.isUnsaved = true)"
        />
      </template>
      <RolePicker
        v-model="collectingEvent.roles_attributes"
        role-type="Collector"
        :create-form="false"
        :autofocus="false"
        @update:model-value="() => (collectingEvent.isUnsaved = true)"
      />
    </SmartSelector>
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
