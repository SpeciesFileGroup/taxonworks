<template>
  <VBtn
    medium
    color="primary"
    @click="clone"
  >
    Clone last attribution
  </VBtn>
</template>

<script setup>
import { ref } from 'vue'
import { Attribution } from '@/routes/endpoints'
import VBtn from '@/components/ui/VBtn/index.vue'

const emit = defineEmits(['clone'])

const isLoading = ref(false)

function makeRole({ type, person, organization }) {
  return {
    type,
    ...(person
      ? { person_id: person.id, person }
      : { organization_id: organization.id, organization })
  }
}

function makeCloneAttribution(item) {
  return {
    copyright_year: item.copyright_year,
    license: item.license,
    creator_roles: item?.creator_roles?.map(makeRole) || [],
    editor_roles: item?.editor_roles?.map(makeRole) || [],
    owner_roles: item?.owner_roles?.map(makeRole) || [],
    copyright_holder_roles: item?.copyright_holder_roles?.map(makeRole) || []
  }
}

async function clone() {
  isLoading.value = true

  try {
    const { body } = await Attribution.where({
      per: 1,
      recent: true
    })

    const [attribution] = body

    if (attribution) {
      emit('clone', makeCloneAttribution(attribution))
    } else {
      TW.workbench.alert.create('No attribution was found', 'notice')
    }
  } catch {
  } finally {
    isLoading.value = true
  }
}
</script>
