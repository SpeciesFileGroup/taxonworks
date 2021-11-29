<template>
  <div>
    <smart-selector
      model="people"
      :target="objectType"
      :klass="objectType"
      label="cached"
      :params="{ role_type: 'Verifier' }"
      :autocomplete-params="{
        roles: ['Verifier']
      }"
      :filter-ids="peopleIds"
      :autocomplete="false"
      @selected="createRole($event.id)">
      <template #header>
        <role-picker
          ref="rolePicker"
          v-model="roles"
          :autofocus="false"
          filter-by-role
          hidden-list
          role-type="Verifier"
          @create="createRole($event.person_id)"/>
      </template>
    </smart-selector>
    <display-list
      :list="list"
      label="object_tag"
    />
  </div>
</template>

<script>

import CRUD from '../../request/crud.js'
import annotatorExtend from '../../components/annotatorExtend.js'
import RolePicker from 'components/role_picker.vue'
import SmartSelector from 'components/ui/SmartSelector.vue'
import DisplayList from 'components/displayList.vue'
import { Role } from 'routes/endpoints'

export default {
  mixins: [CRUD, annotatorExtend],

  components: {
    SmartSelector,
    RolePicker,
    DisplayList
  },

  computed: {
    validateFields () {
      return this.note.text
    }
  },

  data () {
    return {
      loadOnMounted: false,
      roles: []
    }
  },

  created () {
    Role.where({
      role_type: ['Verifier'],
      object_global_id: this.globalId
    }).then(({ body }) => {
      this.roles = body
    })
  },

  methods: {
    createRole (id) {
      const role = {
        type: 'Verifier',
        person_id: id,
        annotated_global_entity: this.globalId
      }

      Role.create({ role }).then(({ body }) => {
        this.list.push(body)
      })
    }
  }
}
</script>
