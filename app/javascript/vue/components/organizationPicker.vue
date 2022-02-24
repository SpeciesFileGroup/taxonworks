<template>
  <div class="horizontal-left-content organization-picker">
    <autocomplete
      class="margin-small-right"
      url="/organizations/autocomplete"
      param="term"
      label="label"
      placeholder="Search an organization"
      ref="autocomplete"
      @found="nothing = !$event"
      @getInput="organization.name = $event"
      @getItem="setOrganization"
      :clear-after="true"
    />
    <button
      v-if="nothing"
      type="button"
      @click="showModal = true"
      class="button normal-input button-default">
      New
    </button>
    <default-pin
      class="button-circle"
      type="Organization"
      @get-item="setOrganization({ id: $event.id, label: $event.label })"
      section="Organizations"/>
    <modal-component
      v-if="showModal"
      @close="showModal = false">
      <template #header>
        <h3>Create organization</h3>
      </template>
      <template #body>
        <div class="horizontal-left-content align-start">
          <div class="margin-medium-right">
            <div class="field">
              <label>Name</label>
              <input
                type="text"
                v-model="organization.name">
            </div>
            <div class="field">
              <label>Alternate name</label>
              <input
                type="text"
                v-model="organization.alternate_name">
            </div>
            <div class="field">
              <label>Description</label>
              <textarea
                type="text"
                rows="2"
                v-model="organization.description"/>
            </div>
            <div class="field">
              <label>Disambiguating description</label>
              <textarea
                type="text"
                rows="2"
                v-model="organization.disambiguating_description"/>
            </div>
            <div class="field">
              <label>Address</label>
              <textarea
                type="text"
                rows="5"
                v-model="organization.address"/>
            </div>
          </div>
          <div class="margin-medium-right">
            <div class="field">
              <label>Telephone</label>
              <input
                type="text"
                v-model="organization.telephone">
            </div>
            <div class="field">
              <label>Email</label>
              <input
                type="email"
                v-model="organization.email">
            </div>
            <div class="field">
              <label>Duns</label>
              <input
                type="text"
                v-model="organization.duns">
            </div>
            <div class="field">
              <label>Global location number</label>
              <input
                type="text"
                v-model="organization.global_location_number">
            </div>
            <div class="field">
              <label>Legal name</label>
              <input
                type="text"
                v-model="organization.legal_name">
            </div>
          </div>
          <div>
            <div class="field">
              <label>Area served</label>
              <autocomplete
                url="/geographic_areas/autocomplete"
                placeholder="Search a geographic area"
                param="term"
                label="label_html"
                @getItem="organization.area_served_id = $event.id"
                display="label"/>
            </div>
            <div class="field">
              <label>Same as</label>
              <autocomplete
                url="/organizations/autocomplete"
                placeholder="Search an organization"
                param="term"
                label="label_html"
                @getItem="organization.same_as_id = $event.id"
                display="label"/>
            </div>
            <div class="field">
              <label>Department</label>
              <autocomplete
                url="/organizations/autocomplete"
                placeholder="Search an organization"
                param="term"
                label="label_html"
                @getItem="organization.department_id = $event.id"
                display="label"/>
            </div>
            <div class="field">
              <label>Parent organization</label>
              <autocomplete
                url="/organizations/autocomplete"
                placeholder="Search an organization"
                param="term"
                label="label_html"
                @getItem="organization.parent_organization_id = $event.id"
                display="label"/>
            </div>
          </div>
        </div>
      </template>
      <template #footer>
        <button
          type="button"
          class="button normal-input button-submit"
          @click="createOrganization">
          Create organization
        </button>
      </template>
    </modal-component>
  </div>
</template>

<script>

import Autocomplete from 'components/ui/Autocomplete'
import ModalComponent from 'components/ui/Modal'
import DefaultPin from './getDefaultPin.vue'
import AjaxCall from 'helpers/ajaxCall'

export default {
  components: {
    Autocomplete,
    DefaultPin,
    ModalComponent
  },

  emits: ['getItem'],

  data () {
    return {
      showModal: false,
      nothing: false,
      organization: this.newOrganization()
    }
  },

  watch: {
    showModal (newVal) {
      if (!newVal)
        this.organization = this.newOrganization()
    }
  },

  methods: {
    newOrganization () {
      return {
        name: undefined,
        alternate_name: undefined,
        description: undefined,
        disambiguating_description: undefined,
        same_as_id: undefined,
        address: undefined,
        email: undefined,
        telephone: undefined,
        duns: undefined,
        global_location_number: undefined,
        legal_name: undefined,
        area_served_id: undefined,
        department_id: undefined,
        parent_organization_id: undefined
      }
    },

    createOrganization () {
      AjaxCall('post', '/organizations', { organization: this.organization }).then(response => {
        this.setOrganization(response.body)
        this.showModal = false
        this.nothing = false
        this.$refs.autocomplete.cleanInput()
      })
    },

    setOrganization (organization) {
      this.$emit('getItem', organization)
    }
  }
}
</script>

<style lang="scss">
  .organization-picker {
    label {
      display: block;
    }
    .modal-container {
      background-color: white !important;
      min-width: auto !important;
      width: 600px !important;
    }
  }
</style>
