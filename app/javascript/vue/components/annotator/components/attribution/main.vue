<template>
  <div class="attribution_annotator">
    <div>
      <label>License</label>
      <br>
      <select v-model="attribution.license">
        <option
          v-for="(url, key) in licenses"
          :key="key"
          :value="key">
          {{ key }}: {{ url }}
        </option>
      </select>
    </div>
    <div class="separate-top separate-bottom">
      <label>Copyright year</label>
      <br>
      <input
        class="input-year"
        v-model="attribution.copyright_year"
        type="number">
    </div>
    <switch-component 
      class="separate-top"
      v-model="view"
      :options="smartSelectorList"
      name="role"/>
    <div>
      <role-picker
        v-if="view"
        v-model="roleList"
        :role-type="roleSelected"/>
    </div>
    <div class="separate-top">
      <button
        type="button"
        @click="attribution.id ? updateAttribution() : createNew()"
        :disabled="!validateFields"
        class="button normal-input button-submit save-annotator-button">
        {{ attribution.id ? 'Update' : 'Create' }}
      </button>
    </div>
  </div>
</template>

<script>

import RolePicker from 'components/role_picker'
import SwitchComponent from 'components/switch.vue'
import CRUD from '../../request/crud.js'
import AnnotatorExtended from '../annotatorExtend.js'

export default {
  mixins: [CRUD, AnnotatorExtended],
  components: {
    RolePicker,
    SwitchComponent
  },
  computed: {
    validateFields() {
      return this.attribution.license || this.attribution.copyright_year || this.attribution.roles_attributes.length
    },
    roleSelected() {
      return this.roleTypes[this.smartSelectorList.findIndex((role) => { return role == this.view })]
    },
    roleList: {
      get() {
        return this.rolesList[`${this.view.replace(/([a-z])([A-Z])/g, '$1_$2').toLowerCase()}_roles`]
      },
      set(value) {
        this.$set(this.rolesList, `${this.view.replace(/([a-z])([A-Z])/g, '$1_$2').toLowerCase()}_roles`, value)
      }
    }
  },
  data() {
    return {
      view: undefined,
      licenses: [],
      smartSelectorList: [],
      roleTypes: [],
      rolesList: {
        creator_roles: [],
        owner_roles: [],
        editor_roles: [],
        copyright_holder_roles: []
      },
      attribution: this.newAttribution()
    }
  },
  watch: {
    list(newVal) {
      if(newVal.length) {
        this.setAttribution(newVal[0])
      }
    }
  },
  mounted() {
    this.getList('/attributions/licenses').then(response => {
      this.licenses = response.body
    }) 
    this.getList('/attributions/role_types.json').then(response => {
      this.roleTypes = response.body
      this.smartSelectorList = this.roleTypes.map((role) => {
        return role.substring(11)
      })
    })
  },
  methods: {
    setAttribution(attribution) {
      this.attribution.id = attribution.id,
      this.attribution.copyright_year = attribution.copyright_year
      this.attribution.license = attribution.license
      this.$set(this.rolesList, 'creator_roles', (attribution.hasOwnProperty('creator_roles') ? attribution.creator_roles : []))
      this.$set(this.rolesList, 'editor_roles', (attribution.hasOwnProperty('editor_roles') ? attribution.editor_roles : [])) 
      this.$set(this.rolesList, 'owner_roles', (attribution.hasOwnProperty('owner_roles') ? attribution.owner_roles : []))
      this.$set(this.rolesList, 'copyright_holder_roles', (attribution.hasOwnProperty('copyright_holder_roles') ? attribution.copyright_holder_roles : []))
    },
    newAttribution() {
      return {
        id: undefined,
        copyright_year: undefined,
        license: undefined,
        annotated_global_entity: this.globalId,
        roles_attributes: []
      }
    },
    createNew() {
      this.setRolesAttributes()
      this.create('/attributions', { attribution: this.attribution }).then(response => {
        this.setAttribution(response.body)
        TW.workbench.alert.create('Attribution was successfully created.', 'notice')
      })
    },
    updateAttribution() {
      this.setRolesAttributes()
      this.update(`/attributions/${this.attribution.id}.json`, { attribution: this.attribution }).then(response => {
        this.setAttribution(response.body)
        TW.workbench.alert.create('Attribution was successfully updated.', 'notice')
      })
    },
    setRolesAttributes() {
      this.updateIndex()
      this.attribution.roles_attributes = [].concat.apply([], Object.values(this.rolesList))
    },
    updateIndex() {
      let lengthArrays = 0
      for (let key in this.rolesList) {
        this.rolesList[key] = this.rolesList[key].map((item, index) => {
          item.position = (index + 1) + lengthArrays
          return item
        })
        lengthArrays = lengthArrays + this.rolesList[key].length
      }
    }
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
        width: 90px;
      }
    }
  }
</style>
