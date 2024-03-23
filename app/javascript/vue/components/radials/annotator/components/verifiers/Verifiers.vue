<template>
  <div>
    <SmartSelector
      model="people"
      target="Verifier"
      :klass="objectType"
      label="cached"
      :params="{ role_type: 'Verifier' }"
      :autocomplete-params="{
        roles: ['Verifier']
      }"
      :autocomplete="false"
      @selected="createRole($event.id)"
    >
      <template #header>
        <role-picker
          ref="rolePicker"
          v-model="roles"
          :autofocus="false"
          filter-by-role
          hidden-list
          role-type="Verifier"
          @create="createRole($event.person_id)"
        />
      </template>
    </SmartSelector>
    <TableList
      :list="list"
      :header="['Person', '']"
      :attributes="['object_tag']"
      @delete="removeRole"
    />
  </div>
</template>

<script setup>
import RolePicker from '@/components/role_picker.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import TableList from '@/components/table_list.vue'
import { useSlice } from '@/components/radials/composables'
import { Role } from '@/routes/endpoints'
import { ROLE_VERIFIER } from '@/constants'
import { ref } from 'vue'

const props = defineProps({
  objectId: {
    type: Number,
    required: true
  },

  objectType: {
    type: String,
    required: true
  },

  radialEmit: {
    type: Object,
    required: true
  }
})

const { list, addToList, removeFromList } = useSlice({
  radialEmit: props.radialEmit
})

const roles = ref([])

function createRole(id) {
  const role = {
    type: ROLE_VERIFIER,
    person_id: id,
    role_object_id: props.objectId,
    role_object_type: props.objectType
  }

  Role.create({ role }).then(({ body }) => {
    addToList(body)
  })
}

function removeRole(role) {
  Role.destroy(role.id).then((_) => {
    removeFromList(role)
  })
}

Role.where({
  role_type: [ROLE_VERIFIER],
  role_object_id: props.objectId,
  role_object_type: props.objectType
}).then(({ body }) => {
  list.value = body
})
</script>
