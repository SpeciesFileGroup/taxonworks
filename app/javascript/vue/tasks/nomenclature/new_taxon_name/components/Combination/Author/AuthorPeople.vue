<template>
  <div class="flex-separate">
    <role-picker
      v-model="roles"
      :role-type="ROLE_TAXON_NAME_AUTHOR"
    />
    <v-btn
      color="primary"
      medium
      :disabled="!source || isAlreadyClone"
      @click="cloneFromSource"
    >
      Clone from source
    </v-btn>
  </div>
</template>
<script setup>

import { computed, ref } from 'vue'
import { Source } from 'routes/endpoints'
import { ROLE_TAXON_NAME_AUTHOR } from 'constants/index.js'
import RolePicker from 'components/role_picker.vue'
import VBtn from 'components/ui/VBtn/index.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})
const emit = defineEmits(['update:modelValue'])
const source = ref(null)

const combination = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const roles = computed({
  get: () => {
    const roles = combination.value.roles_attributes

    return roles
      ? roles.sort((a, b) => a.position - b.position)
      : []
  },
  set: value => { combination.value.roles_attributes = value }
})

const isAlreadyClone = computed(() => {
  if (source.value.author_roles.length === 0) return true

  const authorsId = source.value.author_roles.map(author => Number(author.person.id))
  const personsIds = roles.value.map(role => role.person_id || role.person.id)

  return authorsId.every(id => personsIds.includes(id))
})

const cloneFromSource = () => {
  const personsIds = roles.value.map(role => role.person.id)

  const authorsPerson = source.value.author_roles
    .filter(author => !personsIds.includes(Number(author.person.id)))
    .map(author => ({
      person_id: author.person.id,
      type: ROLE_TAXON_NAME_AUTHOR,
      first_name: author.person.first_name,
      last_name: author.person.last_name
    }))

  roles.value = authorsPerson
}

const sourceId = combination.value.origin_citation_attributes?.source_id

if (sourceId) {
  Source.find(sourceId, { extend: ['roles'] }).then(({ body }) => {
    source.value = body
  })
}

</script>
