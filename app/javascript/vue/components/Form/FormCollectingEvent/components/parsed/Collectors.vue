<template>
  <fieldset>
    <legend>Collectors</legend>
    <VSwitch
      v-model="roleView"
      :options="['People', 'Organization']"
    />
    <SmartSelector
      ref="smartSelector"
      :model="isOrganization ? 'organizations' : 'people'"
      target="Collector"
      klass="CollectingEvent"
      :params="{ role_type: 'Collector' }"
      :autocomplete-params="{
        roles: ['Collector']
      }"
      :label="isOrganization ? 'name' : 'cached'"
      :autocomplete="false"
      @selected="addRole"
    >
      <template #header>
        <RolePicker
          hidden-list
          :organization="isOrganization"
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
import { ref, computed } from 'vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import RolePicker from '@/components/role_picker.vue'
import VSwitch from '@/components/ui/VSwitch.vue'

const roleView = ref('People')
const isOrganization = computed(() => roleView.value === 'Organization')

const collectingEvent = defineModel()
const rolepickerRef = ref(null)

function addRole(role) {
  if (isOrganization.value) {
    rolepickerRef.value.addOrganization(role)
  } else {
    rolepickerRef.value.addPerson(role)
  }
}
</script>
