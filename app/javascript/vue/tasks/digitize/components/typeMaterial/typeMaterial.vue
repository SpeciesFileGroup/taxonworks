<template>
  <block-layout>
    <div slot="header">
      <h3>Type material</h3>
    </div>
    <div slot="options">
      <validation-component :show-message="!typeMaterialCheck"/>
    </div>
    <div slot="body">
      <div>
        <label>Taxon name</label>
        <div
          v-if="taxon"
          class="horizontal-left-content">
          <span v-html="taxon.object_tag"/>
          <span
            class="button circle-button btn-delete"
            @click="taxon = undefined"/>
        </div>
        <autocomplete
          v-else
          url="/taxon_names/autocomplete"
          min="2"
          param="term"
          placeholder="Select a taxon name"
          @getItem="selectTaxon"
          label="label"
          :add-params="{
            'type[]': 'Protonym',
            'nomenclature_group[]': 'SpeciesGroup',
            valid: true
        }"/>
      </div>
      <div>
        <label>Type type</label>
        <br>
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
          <option
            :value="undefined"
            selected
            disabled
            v-else>Select a taxon name first</option>
        </select>
      </div>
      <label>Type designator</label>
      <role-picker
        v-model="roles"
        :autofocus="false"
        role-type="TypeDesignator"
        class="types_field"/>
    </div>
  </block-layout>
</template>

<script>

  import Autocomplete from '../../../../components/autocomplete.vue'
  import { GetTypes } from '../../request/resources.js'
  import RolePicker from '../../../../components/role_picker.vue'
  import ActionNames from '../../store/actions/actionNames.js'
  import { GetterNames } from '../../store/getters/getters.js'
  import { MutationNames } from '../../store/mutations/mutations'
  import BlockLayout from '../../../../components/blockLayout.vue'
  import ValidationComponent from '../shared/validate.vue'
  import ValidateTypeMaterial from '../../validations/typeMaterial.js'

  export default {
    components: {
      Autocomplete,
      RolePicker,
      BlockLayout,
      ValidationComponent
    },
    computed: {
      checkForTypeList () {
        return this.types && this.taxon
      },
      taxon: {
        get() {
          return this.$store.getters[GetterNames.GetTypeMaterial].taxon
        },
        set(value) {
          this.$store.commit(MutationNames.SetTypeMaterialTaxon)
        }
      },
      type: {
        get() {
          return this.$store.getters[GetterNames.GetTypeMaterial.type_type]
        },
        set(value) {
          this.$store.commit(MutationNames.SetTypeMaterialType, value)
        }
      },
      roles: {
        get() {
          return this.$store.getters[GetterNames.GetTypeMaterial].type_designator_roles
        },
        set(value) {
          this.$store.commit(MutationNames.SetTypeMaterialRoles, value)
        }
      },
      typeMaterialCheck() {
        return ValidateTypeMaterial(this.$store.getters[GetterNames.GetTypeMaterial])
      }
    },
    data() {
      return {
        types: undefined,
      }
    },
    mounted: function () {
      GetTypes().then(response => {
        this.types = response
      })
    },
    methods: {
      selectTaxon(taxon) {
        this.$store.dispatch(ActionNames.GetTaxon, taxon.id)
      },
    }
  }
</script>

