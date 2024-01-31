<template>
  <div>
    <smart-selector
      model="people"
      target="Verifier"
      :klass="objectType"
      label="cached"
      :params="{ role_type: 'Verifier' }"
      :autocomplete-params="{
        roles: ['Verifier']
      }"
      :filter-ids="peopleIds"
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
    </smart-selector>
    <table-list
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
import { removeFromArray } from '@/helpers/arrays.js'
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
  }
})

const emit = defineEmits(['update-count'])

const roles = ref([])
const list = ref([])

function createRole(id) {
  const role = {
    type: ROLE_VERIFIER,
    person_id: id,
    role_object_id: props.objectId,
    role_object_type: props.objectType
  }

  Role.create({ role }).then(({ body }) => {
    list.value.push(body)
    emit('update-count', list.value.length)
  })
}

function removeRole(role) {
  Role.destroy(role.id).then((_) => {
    removeFromArray(list.value, role)
    emit('update-count', list.value.length)
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
