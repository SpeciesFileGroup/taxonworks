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
      :autocomplete="false"
      label="cached"
      @selected="addRole"
    >
      <template #header>
        <role-picker
          hidden-list
          v-model="collectingEvent.roles_attributes"
          ref="rolepicker"
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

<script>
import { GetterNames } from '../../../../store/getters/getters.js'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import RolePicker from '@/components/role_picker.vue'
import extendCE from '../../mixins/extendCE.js'

export default {
  mixins: [extendCE],

  components: {
    SmartSelector,
    RolePicker
  },

  computed: {
    collectionObject() {
      return this.$store.getters[GetterNames.GetCollectionObject]
    }
  },

  methods: {
    addRole(role) {
      this.$refs.rolepicker.addPerson(role)
    }
  }
}
</script>
