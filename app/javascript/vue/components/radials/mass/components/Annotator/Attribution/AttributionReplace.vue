<template>
  <div class="attribution-replace">
    <div class="replace-section margin-medium-bottom padding-medium-bottom">
      <h3>Replace</h3>
      <div class="switch-radio">
        <input
          type="radio"
          class="normal-input button-active"
          id="replace-license"
          value="license"
          v-model="replaceType"
        />
        <label for="replace-license">License</label>
        <input
          type="radio"
          class="normal-input button-active"
          id="replace-year"
          value="year"
          v-model="replaceType"
        />
        <label for="replace-year">Copyright year</label>
        <input
          type="radio"
          class="normal-input button-active"
          id="replace-role"
          value="role"
          v-model="replaceType"
        />
        <label for="replace-role">Role</label>
      </div>
    </div>

    <div
      v-if="replaceType === 'license'"
      class="replace-section margin-medium-bottom padding-medium-bottom"
    >
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

    <div
      v-if="replaceType === 'year'"
      class="replace-section margin-medium-bottom padding-medium-bottom"
    >
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

    <div
      v-if="replaceType === 'role'"
      class="replace-section margin-medium-bottom"
    >
      <h3>Roles</h3>
      <div class="margin-medium-bottom">
        <label>Role type</label>
        <select
          v-model="roleType"
          class="full_width margin-small-top"
          :disabled="!!roleReplacement"
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
        <hr class="divisor full_width" />
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

      <div
        v-if="roleReplacement"
        class="table-entrys-list margin-medium-top"
      >
        <div class="list-complete-item flex-separate middle">
          <span>{{ roleReplacement.displayText }}</span>
          <VBtn
            circle
            color="primary"
            @click="removeRoleFromList"
          >
            <VIcon
              name="trash"
              x-small
            />
          </VBtn>
        </div>
      </div>
    </div>

    <VBtn
      class="margin-medium-top"
      color="update"
      :disabled="!isValid"
      @click="emitReplace"
    >
      Replace
    </VBtn>
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

const replaceType = ref('license') // license, year, role

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
const roleReplacement = ref(null)

const roleTypeList = computed(() =>
  ROLE_TYPE_ORDER.filter((type) => props.roleTypes.includes(type))
)

const typeHasOrganization = computed(() =>
  roleType.value === ROLE_ATTRIBUTION_OWNER ||
  roleType.value === ROLE_ATTRIBUTION_COPYRIGHT_HOLDER
)

const fromSelectedRole = computed(() => getActiveRole(fromRoleList.value))
const toSelectedRole = computed(() => getActiveRole(toRoleList.value))

const hasLicenseReplacement = computed(() => fromLicense.value && toLicense.value)
const hasYearReplacement = computed(() => fromYear.value && toYear.value)
const hasRoleReplacements = computed(() => !!roleReplacement.value)

const isValid = computed(() => {
  if (replaceType.value === 'license') {
    return hasLicenseReplacement.value
  }

  if (replaceType.value === 'year') {
    return hasYearReplacement.value
  }

  return !!roleReplacement.value
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

watch(replaceType, () => {
  fromLicense.value = null
  toLicense.value = null
  fromYear.value = null
  toYear.value = null
  fromRoleList.value = []
  toRoleList.value = []
  roleReplacement.value = null
})

watch(
  [fromSelectedRole, toSelectedRole],
  ([fromRole, toRole]) => {
    if (replaceType.value !== 'role') return
    if (!fromRole || !toRole) return
    if (!roleType.value || roleReplacement.value) return

    addRoleToList()
  }
)

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

  roleReplacement.value = {
    roleType: roleType.value,
    fromRole,
    toRole,
    displayText: `${getRoleTypeLabel(roleType.value)}: ${getRoleLabel(
      fromSelected
    )} → ${getRoleLabel(toSelected)}`
  }

  fromRoleList.value = []
  toRoleList.value = []
}

function removeRoleFromList() {
  roleReplacement.value = null
}

function emitReplace() {
  const replaceAttribution = {}
  const toAttribution = {}

  if (replaceType.value === 'license' && hasLicenseReplacement.value) {
    replaceAttribution.license = fromLicense.value
    toAttribution.license = toLicense.value
  }

  if (replaceType.value === 'year' && hasYearReplacement.value) {
    replaceAttribution.copyright_year = fromYear.value
    toAttribution.copyright_year = toYear.value
  }

  if (replaceType.value === 'role' && hasRoleReplacements.value) {
    replaceAttribution.roles_attributes = [roleReplacement.value.fromRole]
    toAttribution.roles_attributes = [roleReplacement.value.toRole]
  }

  emit('select', [replaceAttribution, toAttribution])
}

function getActiveRole(list) {
  const roles = list || []
  // Always index 0 in practice since we hide the picker after selection.
  return roles[roles.length - 1]
}

// Returns, e.g., 'Creator' instead of 'AttributionCreator'.
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

.pair-grid .divisor {
  grid-column: 1 / -1;
  width: 100%;
}


.replace-section:last-of-type {
  border-bottom: none;
}
</style>
