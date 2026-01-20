<template>
  <div>
    <h3>License</h3>
    <LicenseInput
      v-model="attribution.license"
      :licenses="licenses"
    />

    <div class="separate-top separate-bottom">
      <h3>Copyright year</h3>
      <input
        v-model="attribution.copyright_year"
        type="number"
        class="input-xsmall-width margin-small-top"
      />
    </div>
    <div class="switch-radio separate-bottom">
      <template
        v-for="(item, index) in smartSelectorList"
        :key="item"
      >
        <input
          type="radio"
          class="normal-input button-active"
          :value="item"
          :id="`switch-role-${uid}-${index}`"
          :name="`switch-role-options-${uid}`"
          :checked="item === view"
          @click="view = item"
        />
        <label
          :for="`switch-role-${uid}-${index}`"
          class="capitalize"
        >
          {{ item }}
          <span v-if="roleCount(item)">
            ({{ roleCount(item) }})
          </span>
        </label>
      </template>
    </div>
    <template v-if="view === 'CopyrightHolder' || view === 'Owner'">
      <switch-component
        class="margin-medium-bottom"
        v-model="copyrightHolderType"
        use-index
        :options="copyrightHolderOptions"
      />
      <div v-if="copyrightHolderType">
        <organization-picker @select="addOrganization" />
        <display-list
          label="object_tag"
          @delete="removeOrganization"
          :list="organizationRoleList"
          :soft-delete="true"
        />
      </div>
      <role-picker
        v-else
        v-model="roleList"
        :role-type="roleSelected"
      />
    </template>
    <div v-else>
      <template v-if="view">
        <smart-selector
          ref="smartSelector"
          model="people"
          :target="klass"
          :klass="klass"
          :params="{ role_type: ROLE_COLLECTOR }"
          :autocomplete-params="{
            roles: [ROLE_COLLECTOR]
          }"
          :input-id="`attribution-${uid}-people`"
          label="cached"
          :autocomplete="false"
          @selected="addRole"
        >
          <template #header>
            <role-picker
              hidden-list
              v-model="roleList"
              :autofocus="false"
              :role-type="roleSelected"
            />
          </template>
          <role-picker
            :create-form="false"
            v-model="roleList"
            :autofocus="false"
            :role-type="roleSelected"
          />
        </smart-selector>
      </template>
    </div>
    <div class="separate-top">
      <v-btn
        medium
        :color="buttonColor"
        @click="createNew()"
        :disabled="!validateFields"
      >
        {{ buttonLabel }}
      </v-btn>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, reactive, getCurrentInstance } from 'vue'
import { findRole } from '@/helpers/people/people.js'
import { toSnakeCase } from '@/helpers/strings'
import { CreatePerson } from '@/helpers/people/createPerson'
import {
  ROLE_ATTRIBUTION_COPYRIGHT_HOLDER,
  ROLE_ATTRIBUTION_CREATOR,
  ROLE_ATTRIBUTION_EDITOR,
  ROLE_ATTRIBUTION_OWNER,
  ROLE_COLLECTOR
} from '@/constants/index.js'
import RolePicker from '@/components/role_picker'
import SwitchComponent from '@/components/ui/VSwitch.vue'
import OrganizationPicker from '@/components/organizationPicker'
import DisplayList from '@/components/displayList'
import SmartSelector from '@/components/ui/SmartSelector'
import LicenseInput from './licenseInput.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  klass: {
    type: String,
    required: true
  },

  licenses: {
    type: Array,
    default: () => []
  },

  roleTypes: {
    type: Array,
    default: () => []
  },

  buttonLabel: {
    type: String,
    default: 'Create'
  },

  buttonColor: {
    type: String,
    default: 'create'
  }
})

const emit = defineEmits(['attribution'])
const uid = getCurrentInstance().uid

const validateFields = computed(
  () =>
    attribution.value.license ||
    attribution.value.copyright_year ||
    [].concat.apply([], Object.values(rolesList)).length
)

const roleSelected = computed(() => {
  const index = smartSelectorList.value.findIndex((role) => role === view.value)

  return orderedRoleTypes.value[index]
})

const roleList = computed({
  get: () => rolesList[`${toSnakeCase(view.value)}_roles`],
  set: (value) => {
    rolesList[`${toSnakeCase(view.value)}_roles`] = value
  }
})

const view = ref(undefined)
const ROLE_TYPE_ORDER = [
  ROLE_ATTRIBUTION_CREATOR,
  ROLE_ATTRIBUTION_EDITOR,
  ROLE_ATTRIBUTION_OWNER,
  ROLE_ATTRIBUTION_COPYRIGHT_HOLDER
]

const orderedRoleTypes = computed(() =>
  ROLE_TYPE_ORDER.filter((type) => props.roleTypes.includes(type))
)

const smartSelectorList = computed(() =>
  orderedRoleTypes.value.map((role) => role.substring(11))
)
const rolesList = reactive({
  creator_roles: [],
  owner_roles: [],
  owner_organization_roles: [],
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
const organizationRoleList = computed(() =>
  view.value === 'Owner'
    ? rolesList.owner_organization_roles
    : rolesList.copyright_organization_roles
)
const copyrightHolderOptions = computed(() => {
  const lists =
    view.value === 'Owner'
      ? [rolesList.owner_organization_roles, rolesList.owner_roles]
      : [rolesList.copyright_organization_roles, rolesList.copyright_holder_roles]

  return ['person', 'organization'].map((label) => {
    const count = []
      .concat(...lists)
      .filter((item) => item.agent_type === label).length

    return label + (count ? ` (${count})` : '')
  })
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
      position: index + 1 + lengthArrays
    }))

    lengthArrays = lengthArrays + rolesList[key].length
  }
}

const addOrganization = (organization) => {
  const roleType =
    view.value === 'Owner'
      ? ROLE_ATTRIBUTION_OWNER
      : ROLE_ATTRIBUTION_COPYRIGHT_HOLDER
  const targetList =
    view.value === 'Owner'
      ? rolesList.owner_organization_roles
      : rolesList.copyright_organization_roles

  targetList.push({
    organization_id: organization.id,
    type: roleType,
    object_tag: organization?.object_tag || organization.label,
    agent_type: 'organization'
  })
}

const removeOrganization = (organization) => {
  const targetList =
    view.value === 'Owner'
      ? rolesList.owner_organization_roles
      : rolesList.copyright_organization_roles
  const index = organization?.id
    ? targetList.findIndex((item) => item?.id === organization.id)
    : targetList.findIndex(
        (item) => item?.organization_id === organization.organization_id
      )

  targetList.splice(index, 1)
}

const addRole = (role) => {
  if (!findRole(roleList.value, role.id)) {
    roleList.value.push(CreatePerson(role, roleSelected.value))
  }
}

const roleCount = (label) => {
  const key = `${toSnakeCase(label)}_roles`

  if (label === 'Owner') {
    return (
      rolesList.owner_roles.length + rolesList.owner_organization_roles.length
    )
  }

  if (label === 'CopyrightHolder') {
    return (
      rolesList.copyright_holder_roles.length +
      rolesList.copyright_organization_roles.length
    )
  }

  return rolesList[key]?.length || 0
}
</script>

<style lang="scss">
.attribution_annotator {
  .switch-radio {
    label {
      width: 120px;
    }
  }
}
</style>
