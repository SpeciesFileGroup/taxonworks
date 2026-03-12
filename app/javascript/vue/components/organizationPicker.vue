<template>
  <div class="horizontal-left-content organization-picker">
    <VAutocomplete
      class="margin-small-right"
      ref="autocomplete"
      url="/organizations/autocomplete"
      param="term"
      label="label"
      placeholder="Search an organization"
      clear-after
      @found="nothing = !$event"
      @get-input="(item) => (organization.name = item)"
      @get-item="loadOrganization"
    />
    <button
      v-if="showNewButton && nothing"
      type="button"
      @click="isModalVisible = true"
      class="button normal-input button-default"
    >
      New
    </button>
    <DefaultPin
      class="button-circle"
      type="Organization"
      section="Organizations"
      @get-item="loadOrganization"
    />
    <VModal
      v-if="isModalVisible"
      @close="isModalVisible = false"
    >
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
                v-model="organization.name"
              />
            </div>
            <div class="field">
              <label>Alternate name</label>
              <input
                type="text"
                v-model="organization.alternate_name"
              />
            </div>
            <div class="field">
              <label>Description</label>
              <textarea
                type="text"
                rows="2"
                v-model="organization.description"
              />
            </div>
            <div class="field">
              <label>Disambiguating description</label>
              <textarea
                type="text"
                rows="2"
                v-model="organization.disambiguating_description"
              />
            </div>
            <div class="field">
              <label>Address</label>
              <textarea
                type="text"
                rows="5"
                v-model="organization.address"
              />
            </div>
          </div>
          <div class="margin-medium-right">
            <div class="field">
              <label>Telephone</label>
              <input
                type="text"
                v-model="organization.telephone"
              />
            </div>
            <div class="field">
              <label>Email</label>
              <input
                type="email"
                v-model="organization.email"
              />
            </div>
            <div class="field">
              <label>Duns</label>
              <input
                type="text"
                v-model="organization.duns"
              />
            </div>
            <div class="field">
              <label>Global location number</label>
              <input
                type="text"
                v-model="organization.global_location_number"
              />
            </div>
            <div class="field">
              <label>Legal name</label>
              <input
                type="text"
                v-model="organization.legal_name"
              />
            </div>
          </div>
          <div>
            <div class="field">
              <label>Area served</label>
              <VAutocomplete
                url="/geographic_areas/autocomplete"
                placeholder="Search a geographic area"
                param="term"
                label="label_html"
                @get-item="organization.area_served_id = $event.id"
                display="label"
              />
            </div>
            <div class="field">
              <label>Same as</label>
              <VAutocomplete
                url="/organizations/autocomplete"
                placeholder="Search an organization"
                param="term"
                label="label_html"
                @get-item="organization.same_as_id = $event.id"
                display="label"
              />
            </div>
            <div class="field">
              <label>Department</label>
              <VAutocomplete
                url="/organizations/autocomplete"
                placeholder="Search an organization"
                param="term"
                label="label_html"
                display="label"
                @get-item="organization.department_id = $event.id"
              />
            </div>
            <div class="field">
              <label>Parent organization</label>
              <VAutocomplete
                url="/organizations/autocomplete"
                placeholder="Search an organization"
                param="term"
                label="label_html"
                display="label"
                @get-item="organization.parent_organization_id = $event.id"
              />
            </div>
          </div>
        </div>
      </template>
      <template #footer>
        <button
          type="button"
          class="button normal-input button-submit"
          @click="createOrganization"
        >
          Create organization
        </button>
      </template>
    </VModal>
  </div>
</template>

<script setup>
import VAutocomplete from '@/components/ui/Autocomplete'
import VModal from '@/components/ui/Modal'
import DefaultPin from '@/components/ui/Button/ButtonPinned.vue'
import { Organization } from '@/routes/endpoints'
import { ref, useTemplateRef, watch } from 'vue'

const emit = defineEmits(['select'])

const props = defineProps({
  showNewButton: {
    type: Boolean,
    default: true
  }
})

const isModalVisible = ref(false)
const nothing = ref(false)
const organization = ref(makeOrganization())
const autocompleteRef = useTemplateRef('autocomplete')

watch(isModalVisible, (newVal) => {
  if (!newVal) {
    organization.value = makeOrganization()
  }
})

function makeOrganization() {
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
}

function createOrganization() {
  Organization.create({ organization: organization.value }).then(({ body }) => {
    setOrganization(body)
    isModalVisible.value = false
    nothing.value = false
    autocompleteRef.value.cleanInput()
  })
}

function loadOrganization(item) {
  Organization.find(item.id).then(({ body }) => {
    emit('select', body)
  })
}

function setOrganization(organization) {
  emit('select', organization)
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
