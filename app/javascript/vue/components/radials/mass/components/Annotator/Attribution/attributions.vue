<template>
  <div>
    <license-input v-model="attribution.license"/>

    <div class="separate-top separate-bottom">
      <label>Copyright year</label>
      <br>
      <input
        class="input-year"
        v-model="attribution.copyright_year"
        type="number">
    </div>
    <div class="switch-radio separate-bottom">
      <template
        v-for="(item, index) in smartSelectorList"
        :key="item">
        <input
          type="radio"
          class="normal-input button-active"
          :value="item"
          :id="`switch-role-${index}`"
          :name="`switch-role-options`"
          :checked="item === view"
          @click="view = item">
        <label
          :for="`switch-role-${index}`"
          class="capitalize">
          {{ item }}
          <span v-if="rolesList[`${toSnakeCase(item)}_roles`].length">
            ({{ rolesList[`${toSnakeCase(item)}_roles`].length }})
          </span>
        </label>
      </template>
    </div>
    <template v-if="view === 'CopyrightHolder'">
      <switch-component
        class="margin-medium-bottom"
        v-model="copyrightHolderType"
        use-index
        :options="copyrightHolderOptions"/>
      <div v-if="copyrightHolderType">
        <organization-picker @getItem="addOrganization"/>
        <display-list
          label="object_tag"
          @delete="removeOrganization"
          :list="rolesList.copyright_organization_roles"/>
      </div>
      <role-picker
        v-else
        v-model="roleList"
        :role-type="roleSelected"/>
    </template>
    <div v-else>
      <template v-if="view">
        <smart-selector
          ref="smartSelector"
          model="people"
          :target="props.type"
          :klass="props.type"
          :params="{ role_type: ROLE_COLLECTOR }"
          :autocomplete-params="{
            roles: [ROLE_COLLECTOR]
          }"
          label="cached"
          :autocomplete="false"
          @selected="addRole">
          <template #header>
            <role-picker
              hidden-list
              v-model="roleList"
              :autofocus="false"
              :role-type="roleSelected"/>
          </template>
          <role-picker
            :create-form="false"
            v-model="roleList"
            :autofocus="false"
            :role-type="roleSelected"/>
        </smart-selector>
      </template>
    </div>
    <div class="separate-top">
      <v-btn
        medium
        color="create"
        @click="createNew()"
        :disabled="!validateFields"
      >
        Create
      </v-btn>
    </div>
  </div>
</template>

<script setup>

import { computed, ref, reactive } from 'vue'
import { findRole } from 'helpers/people/people.js'
import { toSnakeCase } from 'helpers/strings'
import { Attribution } from 'routes/endpoints'
import { CreatePerson } from 'helpers/people/createPerson'
import {
  ATTRIBUTION_COPYRIGHT_HOLDER,
  ROLE_COLLECTOR
} from 'constants/index.js'
import RolePicker from 'components/role_picker'
import SwitchComponent from 'components/switch.vue'
import OrganizationPicker from 'components/organizationPicker'
import DisplayList from 'components/displayList'
import SmartSelector from 'components/ui/SmartSelector'
import LicenseInput from './licenseInput.vue'
import VBtn from 'components/ui/VBtn/index.vue'

const props = defineProps({
  type: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['attribution'])

const validateFields = computed(() =>
  attribution.value.license ||
  attribution.value.copyright_year ||
  [].concat.apply([], Object.values(rolesList)).length
)

const roleSelected = computed(() => {
  const index = smartSelectorList.value.findIndex(role => role === view.value)

  return roleTypes.value[index]
})

const roleList = computed({
  get: () => rolesList[`${toSnakeCase(view.value)}_roles`],
  set: value => { rolesList[`${toSnakeCase(view.value)}_roles`] = value }
})

const view = ref(undefined)
const smartSelectorList = ref([])
const roleTypes = ref([])
const rolesList = reactive({
  creator_roles: [],
  owner_roles: [],
  editor_roles: [],
  copyright_holder_roles: [],
  copyright_organization_roles: []
})
const attribution = ref({
  copyright_year: undefined,
  license: null,
  roles_attributes: []
})

const copyrightHolderType = ref(0)
const copyrightHolderOptions = computed(() =>
  ['person', 'organization'].map(label => {
    const count = [].concat(
      rolesList.copyright_organization_roles,
      rolesList.copyright_holder_roles
    ).filter(item => item.agent_type === label).length

    return label + (count ? ` (${count})` : '')
  })
)

Attribution.roleTypes().then(({ body }) => {
  roleTypes.value = body
  smartSelectorList.value = roleTypes.value.map(role => role.substring(11))
})

const createNew = () => {
  updateIndex()
  emit('attribution', {
    ...attribution.value,
    roles_attributes: [].concat.apply([], Object.values(rolesList))
  })
}

const updateIndex = () => {
  let lengthArrays = 0

  for (const key in rolesList) {
    rolesList[key] = rolesList[key].map((item, index) => ({
      ...item,
      position: (index + 1) + lengthArrays
    }))

    lengthArrays = lengthArrays + rolesList[key].length
  }
}

const addOrganization = organization => {
  rolesList.copyright_organization_roles.push({
    organization_id: organization.id,
    type: ATTRIBUTION_COPYRIGHT_HOLDER,
    object_tag: organization?.object_tag || organization.label
  })
}

const removeOrganization = organization => {
  const index = organization?.id
    ? rolesList.copyright_organization_roles.findIndex(item => item?.id === organization.id)
    : rolesList.copyright_organization_roles.findIndex(item => item?.organization_id === organization.organization_id)

  rolesList.copyright_organization_roles.splice(index, 1)
}

const addRole = role => {
  if (!findRole(roleList.value, role.id)) {
    roleList.value.push(CreatePerson(role, roleSelected.value))
  }
}

</script>

<style lang="scss">
  .attribution_annotator {
    .input-year {
      width: 80px;
    }
    .switch-radio {
      label {
        width: 120px;
      }
    }
  }
</style>
