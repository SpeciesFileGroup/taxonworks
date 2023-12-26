<template>
  <div class="panel content">
    <fieldset>
      <legend>Collector</legend>
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
            v-model="collectorRoleList"
            ref="rolepicker"
            :autofocus="false"
            role-type="Collector"
          />
        </template>
        <role-picker
          :create-form="false"
          v-model="collectorRoleList"
          :autofocus="false"
          role-type="Collector"
        />
      </smart-selector>
    </fieldset>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import RolePicker from '@/components/role_picker.vue'
import useStore from '@/tasks/collecting_events/stepwise/collectors/composables/useStore'

const { collectorRoleList } = useStore()

const rolepicker = ref(null)

function addRole(role) {
  rolepicker.value.addPerson(role)
}
</script>
