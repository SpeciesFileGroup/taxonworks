<template>
  <block-layout>
    <div slot="header">
      <h3>Type material</h3>
    </div>
    <div slot="options">
      <validation-component :show-message="!typeMaterialCheck"/>
    </div>
    <div slot="body">
      <div
        v-if="typeMaterial.id"
        class="horizontal-left-content">
        <span v-html="typeMaterial.object_tag"/>
        <span
          class="button circle-button btn-delete"
          @click="destroyTypeMateria(typeMaterial.id)"/>
      </div>
      <template v-else>
        <div class="separate-bottom">
          <fieldset>
            <legend>Taxon name</legend>
            <smart-selector
              v-model="viewTaxon"
              class="separate-bottom"
              name="taxon-type"
              :options="optionsTaxon"/>
            <div
              v-if="taxon"
              class="horizontal-left-content">
              <span v-html="taxon.object_tag"/>
              <span
                class="button circle-button btn-undo button-default"
                @click="taxon = undefined"/>
            </div>
            <template>
              <autocomplete
                v-if="viewTaxon == 'search'"
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
              <ul
                v-else
                class="no_bullets">
                <li
                  v-for="item in listsTaxon[viewTaxon]"
                  :key="item.id"
                  :value="item.id">
                  <label
                    @click="selectTaxon(item)">
                    <input
                      name="taxon-type-material"
                      :value="item.id"
                      type="radio">
                    <span v-html="item.object_tag"/>
                  </label>
                </li>
              </ul>
            </template>
          </fieldset>
        </div>
        <div class="separate-bottom">
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
        <fieldset>
          <legend>Type designator</legend>
          <smart-selector
            v-model="view"
            class="separate-bottom"
            name="type-designator"
            :options="options"/>
          <div
            v-if="view != 'new/Search'"
            class="separate-bottom">
            <ul class="no_bullets">
              <li
                v-for="item in lists[view]"
                v-if="!roleExist(item.id)"
                :key="item.id">
                <label>
                  <input
                    type="radio"
                    @click="addRole(item)"
                    :checked="roleExist(item.id)">
                  {{ item.object_tag }}
                </label>
              </li>
            </ul>
          </div>
          <role-picker
            v-model="roles"
            :autofocus="false"
            role-type="TypeDesignator"
            class="types_field"/>
        </fieldset>
      </template>
    </div>
  </block-layout>
</template>

<script>

  import Autocomplete from '../../../../components/autocomplete.vue'
  import { 
    GetTypes, 
    DestroyTypeMaterial, 
    GetTypeDesignatorSmartSelector,
    GetTaxonNameSmartSelector } from '../../request/resources.js'
  import RolePicker from '../../../../components/role_picker.vue'
  import ActionNames from '../../store/actions/actionNames.js'
  import { GetterNames } from '../../store/getters/getters.js'
  import { MutationNames } from '../../store/mutations/mutations'
  import BlockLayout from '../../../../components/blockLayout.vue'
  import ValidationComponent from '../shared/validate.vue'
  import ValidateTypeMaterial from '../../validations/typeMaterial.js'
  import SmartSelector from 'components/switch.vue'
  import CreatePerson from '../../helpers/createPerson.js'
  import orderSmartSelector from '../../helpers/orderSmartSelector.js'
  import selectFirstSmartOption from '../../helpers/selectFirstSmartOption'

  export default {
    components: {
      Autocomplete,
      RolePicker,
      BlockLayout,
      ValidationComponent,
      SmartSelector
    },
    computed: {
      checkForTypeList () {
        return this.types && this.taxon
      },
      typeMaterial() {
        return this.$store.getters[GetterNames.GetTypeMaterial]
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
          return this.$store.getters[GetterNames.GetTypeMaterial].type_type
        },
        set(value) {
          this.$store.commit(MutationNames.SetTypeMaterialType, value)
        }
      },
      roles: {
        get() {
          return this.$store.getters[GetterNames.GetTypeMaterial].roles_attributes
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
        options: [],
        optionsTaxon: [],
        lists: {},
        listsTaxon: {},
        view: 'new/Search',
        viewTaxon: 'search'
      }
    },
    mounted: function () {
      GetTypes().then(response => {
        this.types = response
      })
      GetTypeDesignatorSmartSelector().then(response => {
        this.options = orderSmartSelector(Object.keys(response))
        this.lists = response
        this.options.push("new/Search")
        this.view = selectFirstSmartOption(response, this.options)
      })
      GetTaxonNameSmartSelector().then(response => {
        this.optionsTaxon = orderSmartSelector(Object.keys(response))
        this.listsTaxon = response   
        this.optionsTaxon.push("search") 
        this.viewTaxon = selectFirstSmartOption(response, this.optionsTaxon)
      })
    },
    methods: {
      selectTaxon(taxon) {
        this.$store.dispatch(ActionNames.GetTaxon, taxon.id)
      },
      destroyTypeMateria(id) {
        DestroyTypeMaterial(id).then(() => {
          this.$store.commit(MutationNames.NewTypeMaterial)
          TW.workbench.alert.create('Type material was successfully destroyed.', 'notice')
        })
      },
      roleExist(id) {
        return (this.roles.find((role) => {
          return !role.hasOwnProperty('_destroy') && role.hasOwnProperty('person') && role.person.id == id
        }) ? true : false)
      },
      addRole(role) {
        if(!this.roleExist(role.id)) {
          this.roles.push(CreatePerson(role, 'Collector'))
        }
      }
    }
  }
</script>

