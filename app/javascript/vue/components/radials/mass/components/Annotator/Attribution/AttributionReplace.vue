<template>
  <div class="attribution-replace">
    <div class="replace-section margin-medium-bottom padding-medium-bottom">
      <h3>License</h3>
      <div class="pair-grid margin-small-bottom">
        <label>From</label>
        <LicenseInput
          v-model="fromLicense"
          :licenses="licenses"
        />
        <label>To</label>
        <LicenseInput
          v-model="toLicense"
          :licenses="licenses"
        />
      </div>
    </div>

    <div class="replace-section margin-medium-bottom padding-medium-bottom">
      <h3>Copyright year</h3>
      <div class="pair-grid margin-small-bottom">
        <label>From</label>
        <input
          class="input-xsmall-width"
          v-model="fromYear"
          type="number"
        />
        <label>To</label>
        <input
          class="input-xsmall-width"
          v-model="toYear"
          type="number"
        />
      </div>
    </div>

    <div class="replace-section margin-medium-bottom">
      <h3>Roles</h3>
      <div class="margin-medium-bottom">
        <label>Role type</label>
        <select
          v-model="roleType"
          class="full_width margin-small-top"
        >
          <option
            v-for="type in roleTypeList"
            :key="type"
            :value="type"
          >
            {{ getRoleTypeLabel(type) }}
          </option>
        </select>
      </div>

      <div class="pair-grid margin-medium-bottom">
        <label>From</label>
        <div>
          <div
            v-if="fromSelectedRole"
            class="flex-separate middle"
          >
            <span>{{ getRoleLabel(fromSelectedRole) }}</span>
            <VBtn
              circle
              color="primary"
              @click="fromRoleList = []"
            >
              <VIcon name="trash" x-small />
            </VBtn>
          </div>
          <div
            v-else-if="roleType"
          >
            <PeopleSelector
              v-model="fromRoleList"
              :organization="typeHasOrganization"
              :role-type="roleType"
              :show-create-controls="false"
              :autofocus="false"
            />
          </div>
        </div>
        <label>To</label>
        <div>
          <div
            v-if="toSelectedRole"
            class="flex-separate middle"
          >
            <span>{{ getRoleLabel(toSelectedRole) }}</span>
            <VBtn
              circle
              color="primary"
              @click="toRoleList = []"
            >
              <VIcon name="trash" x-small />
            </VBtn>
          </div>
          <div
            v-else-if="roleType"
          >
            <PeopleSelector
              v-model="toRoleList"
              :organization="typeHasOrganization"
              :role-type="roleType"
              :autofocus="false"
            />
          </div>
        </div>
      </div>

      <div class="horizontal-left-content gap-small">
        <VBtn
          color="primary"
          :disabled="!canAddRole"
          @click="addRoleToList"
        >
          Add to list
        </VBtn>
        <span
          v-if="isFromDuplicate"
          class="horizontal-left-content gap-small"
        >
          <VIcon
            name="attention"
            color="attention"
            small
          />
          <span>This role/agent combination is already in the list</span>
        </span>
      </div>

      <ul
        v-if="roleReplacements.length"
        class="table-entrys-list margin-medium-top"
      >
        <li
          v-for="(item, index) in roleReplacements"
          :key="index"
          class="list-complete-item flex-separate middle"
        >
          <span>{{ item.displayText }}</span>
          <VBtn
            circle
            color="primary"
            @click="removeRoleFromList(index)"
          >
            <VIcon
              name="trash"
              x-small
            />
          </VBtn>
        </li>
      </ul>
    </div>

    <VBtn
      class="margin-medium-top"
      color="update"
      :disabled="!isValid"
      @click="emitReplace"
    >
      Replace
    </VBtn>
    <div
      v-if="validationMessage"
      class="text-warning-color margin-small-top"
    >
      {{ validationMessage }}
    </div>
    <div class="text-small-size margin-small-top">
      Note: replace accepts a single attribute or one role at a time. Counts
      reflect only actual replacements; no-op rows are not treated as failures.
    </div>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import {
  ROLE_ATTRIBUTION_COPYRIGHT_HOLDER,
  ROLE_ATTRIBUTION_CREATOR,
  ROLE_ATTRIBUTION_EDITOR,
  ROLE_ATTRIBUTION_OWNER
} from '@/constants'
import LicenseInput from './licenseInput.vue'
import PeopleSelector from '@/components/radials/annotator/components/attribution/PeopleSelector.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const ROLE_TYPE_ORDER = [
  ROLE_ATTRIBUTION_CREATOR,
  ROLE_ATTRIBUTION_EDITOR,
  ROLE_ATTRIBUTION_OWNER,
  ROLE_ATTRIBUTION_COPYRIGHT_HOLDER
]

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
  }
})

const emit = defineEmits(['select'])

// License
const fromLicense = ref(null)
const toLicense = ref(null)

// Copyright year
const fromYear = ref(null)
const toYear = ref(null)

// Roles
const roleType = ref(null)
const fromRoleList = ref([])
const toRoleList = ref([])
const roleReplacements = ref([])

const roleTypeList = computed(() =>
  ROLE_TYPE_ORDER.filter((type) => props.roleTypes.includes(type))
)

const typeHasOrganization = computed(() =>
  roleType.value === ROLE_ATTRIBUTION_OWNER ||
  roleType.value === ROLE_ATTRIBUTION_COPYRIGHT_HOLDER
)

const fromSelectedRole = computed(() => getActiveRole(fromRoleList.value))
const toSelectedRole = computed(() => getActiveRole(toRoleList.value))

const isFromDuplicate = computed(() => {
  const fromRole = getActiveRole(fromRoleList.value)
  if (!fromRole || !roleType.value) return false
  const agentId = getRoleAgentId(fromRole)
  const isOrganization = isOrganizationRole(fromRole)

  return roleReplacements.value.some((item) => {
    if (item.roleType !== roleType.value) return false
    return isOrganization
      ? item.fromRole.organization_id === agentId
      : item.fromRole.person_id === agentId
  })
})

const hasAnyLicenseInput = computed(() => fromLicense.value || toLicense.value)
const hasAnyYearInput = computed(() => fromYear.value || toYear.value)

const canAddRole = computed(() => {
  const fromRole = getActiveRole(fromRoleList.value)
  const toRole = getActiveRole(toRoleList.value)

  if (hasAnyLicenseInput.value || hasAnyYearInput.value) {
    return false
  }

  return (
    roleType.value &&
    fromRole &&
    toRole &&
    !isFromDuplicate.value &&
    roleReplacements.value.length === 0
  )
})

const hasLicenseReplacement = computed(() => fromLicense.value && toLicense.value)
const hasYearReplacement = computed(() => fromYear.value && toYear.value)
const hasRoleReplacements = computed(() => roleReplacements.value.length > 0)

const isValid = computed(() => {
  const types = selectedTypes.value

  if (types.length !== 1) {
    return false
  }

  if (types[0] === 'license') {
    return hasLicenseReplacement.value
  }

  if (types[0] === 'year') {
    return hasYearReplacement.value
  }

  return roleReplacements.value.length === 1
})

const selectedTypes = computed(() => {
  const types = []

  if (hasAnyLicenseInput.value) {
    types.push('license')
  }
  if (hasAnyYearInput.value) {
    types.push('year')
  }
  if (hasRoleReplacements.value) {
    types.push('roles')
  }

  return types
})

const validationMessage = computed(() => {
  if (!selectedTypes.value.length) return ''
  if (selectedTypes.value.length > 1) {
    return 'Choose only one: license, copyright year, or one role.'
  }
  if (selectedTypes.value[0] === 'license' && !hasLicenseReplacement.value) {
    return 'Choose both from and to license.'
  }
  if (selectedTypes.value[0] === 'year' && !hasYearReplacement.value) {
    return 'Choose both from and to year.'
  }
  if (selectedTypes.value[0] === 'roles' && roleReplacements.value.length !== 1) {
    return 'Choose exactly one role replacement.'
  }
  return ''
})

// roleTypes are loaded async
watch(
  () => props.roleTypes,
  (types) => {
    if (types.length && !roleType.value) {
      roleType.value = types[0]
    }
  },
  { immediate: true }
)

watch(roleType, () => {
  fromRoleList.value = []
  toRoleList.value = []
})

function addRoleToList() {
  const fromSelected = getActiveRole(fromRoleList.value)
  const toSelected = getActiveRole(toRoleList.value)
  if (!fromSelected || !toSelected) return

  const fromRole = {
    type: roleType.value,
    ...(isOrganizationRole(fromSelected)
      ? { organization_id: getRoleAgentId(fromSelected) }
      : { person_id: getRoleAgentId(fromSelected) })
  }
  const toRole = {
    type: roleType.value,
    ...(isOrganizationRole(toSelected)
      ? { organization_id: getRoleAgentId(toSelected) }
      : { person_id: getRoleAgentId(toSelected) })
  }

  roleReplacements.value.push({
    roleType: roleType.value,
    fromRole,
    toRole,
    displayText: `${getRoleTypeLabel(roleType.value)}: ${getRoleLabel(
      fromSelected
    )} → ${getRoleLabel(toSelected)}`
  })

  fromRoleList.value = []
  toRoleList.value = []
}

function removeRoleFromList(index) {
  roleReplacements.value.splice(index, 1)
}

function emitReplace() {
  const replaceAttribution = {}
  const toAttribution = {}

  if (hasLicenseReplacement.value) {
    replaceAttribution.license = fromLicense.value
    toAttribution.license = toLicense.value
  }

  if (hasYearReplacement.value) {
    replaceAttribution.copyright_year = fromYear.value
    toAttribution.copyright_year = toYear.value
  }

  if (hasRoleReplacements.value) {
    replaceAttribution.roles_attributes = roleReplacements.value.map((r) => r.fromRole)
    toAttribution.roles_attributes = roleReplacements.value.map((r) => r.toRole)
  }

  emit('select', [replaceAttribution, toAttribution])
}

function getActiveRole(list) {
  const roles = list || []
  return roles[roles.length - 1]
}

// returns, e.g., 'Creator' instead of 'AttributionCreator'
function getRoleTypeLabel(type) {
  return type?.substring(11) || ''
}

function getRoleAgentId(role) {
  return (
    role?.person_id ||
    role?.person?.id ||
    role?.organization_id ||
    role?.organization?.id
  )
}

function isOrganizationRole(role) {
  return !!(role?.organization_id || role?.organization?.id)
}

function getRoleLabel(role) {
  return (
    role?.name ||
    role?.organization?.name ||
    role?.cached ||
    role?.person?.cached ||
    role?.label
  )
}
</script>

<style scoped>
.replace-section {
  border-bottom: 1px solid var(--border-color);
}

.pair-grid {
  display: grid;
  grid-template-columns: auto 1fr;
  column-gap: 12px;
  row-gap: 8px;
  align-items: center;
}

.pair-grid label {
  text-align: right;
}

.replace-section:last-of-type {
  border-bottom: none;
}
</style>
