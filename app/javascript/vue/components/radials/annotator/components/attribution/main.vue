<template>
  <div class="attribution_annotator">
    <VSpinner v-if="isLoading" />
    <LicenseSelector
      v-model="attribution.license"
      v-model:year="attribution.copyright_year"
    />
    <VSwitch
      class="margin-medium-bottom"
      :options="ROLE_TYPE_LIST"
      use-index
      v-model="roleType"
    />

    <PeopleSelector
      :organization="typeHasOrganization"
      :role-type="roleType"
      v-model="roleList[roleType]"
    />

    <div class="margin-medium-top">
      <button
        type="button"
        :disabled="!validateFields"
        class="button normal-input button-submit save-annotator-button"
        @click="() => saveAttribution()"
      >
        {{ attribution.id ? 'Update' : 'Create' }}
      </button>
    </div>
  </div>
</template>

<script setup>
import VSwitch from '@/components/ui/VSwitch.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import LicenseSelector from './LicenseSelector.vue'
import PeopleSelector from './PeopleSelector.vue'
import { Attribution } from '@/routes/endpoints'
import { computed, ref } from 'vue'
import {
  ROLE_ATTRIBUTION_COPYRIGHT_HOLDER,
  ROLE_ATTRIBUTION_CREATOR,
  ROLE_ATTRIBUTION_EDITOR,
  ROLE_ATTRIBUTION_OWNER
} from '@/constants'

const props = defineProps({
  metadata: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['updateCount'])

const attribution = ref(makeAttribution())
const roleList = ref({
  [ROLE_ATTRIBUTION_CREATOR]: [],
  [ROLE_ATTRIBUTION_EDITOR]: [],
  [ROLE_ATTRIBUTION_OWNER]: [],
  [ROLE_ATTRIBUTION_COPYRIGHT_HOLDER]: []
})

const roleType = ref(ROLE_ATTRIBUTION_CREATOR)

const ROLE_TYPE_LIST = computed(() => ({
  [ROLE_ATTRIBUTION_CREATOR]: `Creator (${getCount(
    roleList.value[ROLE_ATTRIBUTION_CREATOR]
  )})`,
  [ROLE_ATTRIBUTION_EDITOR]: `Editor (${getCount(
    roleList.value[ROLE_ATTRIBUTION_EDITOR]
  )})`,
  [ROLE_ATTRIBUTION_OWNER]: `Owner (${getCount(
    roleList.value[ROLE_ATTRIBUTION_OWNER]
  )})`,
  [ROLE_ATTRIBUTION_COPYRIGHT_HOLDER]: `Copyright Holder (${getCount(
    roleList.value[ROLE_ATTRIBUTION_COPYRIGHT_HOLDER]
  )})`
}))

const typeHasOrganization = computed(
  () =>
    roleType.value === ROLE_ATTRIBUTION_OWNER ||
    roleType.value === ROLE_ATTRIBUTION_COPYRIGHT_HOLDER
)

function getCount(list) {
  return list.filter((item) => !item._destroy).length
}

const validateFields = computed(
  () =>
    attribution.value.license ||
    attribution.value.copyright_year ||
    [].concat([], ...Object.values(roleList.value)).length
)

function makeAttribution(item) {
  return {
    id: item?.id,
    copyright_year: item?.copyright_year,
    license: item?.license || null
  }
}

function makeRoleList(item) {
  return {
    [ROLE_ATTRIBUTION_CREATOR]: item?.creator_roles || [],
    [ROLE_ATTRIBUTION_EDITOR]: item?.editor_roles || [],
    [ROLE_ATTRIBUTION_OWNER]: item?.owner_roles || [],
    [ROLE_ATTRIBUTION_COPYRIGHT_HOLDER]: item?.copyright_holder_roles || []
  }
}

function saveAttribution() {
  const payload = {
    ...attribution.value,
    attribution_object_id: props.metadata.object_id,
    attribution_object_type: props.metadata.object_type,
    roles_attributes: [].concat(...Object.values(roleList.value))
  }

  const response = payload.id
    ? Attribution.update(payload.id, { attribution: payload })
    : Attribution.create({ attribution: payload })

  response.then(({ body }) => {
    attribution.value = makeAttribution(body)
    roleList.value = makeRoleList(body)
    emit('updateCount', 1)
    TW.workbench.alert.create('Attribution was successfully created.', 'notice')
  })
}

const isLoading = ref(true)

Attribution.where({
  attribution_object_id: props.metadata.object_id,
  attribution_object_type: props.metadata.object_type
})
  .then(({ body }) => {
    const [item] = body

    attribution.value = makeAttribution(item)
    roleList.value = makeRoleList(item)
  })
  .finally(() => {
    isLoading.value = false
  })
</script>
