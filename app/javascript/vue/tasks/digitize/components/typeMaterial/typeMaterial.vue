<template>
  <div>
    <h2>Type material</h2>
    <label>Taxon name</label>
    <autocomplete
      url="/taxon_names/autocomplete"
      min="2"
      param="term"
      placeholder="Select a taxon name"
      @getItem="taxon = $event"
      label="label"/>
    <label>Type type</label>
    <select
      v-model="type"
      class="normal-input">
      <template v-if="checkForTypeList">
        <option
          class="capitalize"
          :value="key"
          v-for="(item, key) in types[taxon.nomenclatural_code]">{{ key }}
        </option>
      </template>
    </select>
    <label>Type designator</label>
    <role-picker
      v-model="roles"
      role-type="TypeDesignator"
      class="types_field"/>
  </div>
</template>

<script>

  import Autocomplete from '../../../../components/autocomplete.vue'
  import GetTypes from '../request/resources.js'
  import RolePicker from '../../../../components/role_picker.vue'

  export default {
    components: {
      Autocomplete,
      RolePicker
    },
    computed: {
      checkForTypeList () {
        return this.types && this.taxon
      }
    },
    data() {
      return {
        type: undefined,
        taxon: undefined,
        types: undefined,
        roles: []
      }
    },
    mounted: function () {
      GetTypes().then(response => {
        this.types = response
      })
    }
  }
</script>

