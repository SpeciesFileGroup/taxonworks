<template>
  <div class="attribution_annotator">
    <div>
      <label>License</label>
      <br>
      <select v-model="attribution.license">
        <option
          v-for="(license) in licenses"
          :key="license.key"
          :value="license.key">
          <span v-if="license.key != null">
            {{ license.key }} :
          </span>
          {{ license.label }}
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
    <div class="switch-radio separate-bottom">
      <template
        v-for="(item, index) in smartSelectorList">
        <input
          @click="view = item"
          :value="item"
          :id="`switch-role-${index}`"
          :name="`switch-role-options`"
          type="radio"
          :checked="item === view"
          class="normal-input button-active">
        <label
          :for="`switch-role-${index}`"
          class="capitalize">{{ item }}
          <span v-if="rolesList[`${item.replace(/([a-z])([A-Z])/g, '$1_$2').toLowerCase()}_roles`].length">
            ({{ rolesList[`${item.replace(/([a-z])([A-Z])/g, '$1_$2').toLowerCase()}_roles`].length }})
          </span>
        </label>
      </template>
    </div>
    <template v-if="view === 'CopyrightHolder'">
      <switch-component
        class="margin-medium-bottom"
        v-model="copyrightHolderType"
        use-index
        :options="copyrightHolderOptions"/>
      <div v-if="copyrightHolderType">
        <organization-picker @getItem="addOrganization"/>
        <display-list
          label="object_tag"
          @delete="removeOrganization"
          :list="organizationList"/>
      </div>
      <role-picker
        v-else
        v-model="roleList"
        :role-type="roleSelected"/>
    </template>
    <div v-else>
      <template v-if="view">
        <smart-selector
          ref="smartSelector"
          model="people"
          target="CollectingEvent"
          klass="CollectingEvent"
          :params="{ role_type: 'Collector' }"
          :autocomplete-params="{
            roles: ['Collector']
          }"
          :autocomplete="false"
          @selected="addRole">
          <template #header>
            <role-picker
              :hidden-list="true"
              v-model="roleList"
              ref="rolepicker"
              :autofocus="false"
              :role-type="roleSelected"/>
          </template>
          <role-picker
            :create-form="false"
            v-model="roleList"
            :autofocus="false"
            :role-type="roleSelected"/>
        </smart-selector>
      </template>
    </div>
    <div class="separate-top">
      <button
        type="button"
        @click="attribution.id ? updateAttribution() : createNew()"
        :disabled="!attribution.id && !validateFields"
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
import OrganizationPicker from 'components/organizationPicker'
import DisplayList from 'components/displayList'
import SmartSelector from 'components/ui/SmartSelector'

export default {
  mixins: [CRUD, AnnotatorExtended],
  components: {
    RolePicker,
    SwitchComponent,
    OrganizationPicker,
    DisplayList,
    SmartSelector
  },
  computed: {
    validateFields () {
      return this.attribution.license || this.attribution.copyright_year || [].concat.apply([], Object.values(this.rolesList)).length
    },

    roleSelected () {
      const index = this.smartSelectorList.findIndex((role) => role === this.view)

      return this.roleTypes[index]
    },

    roleList: {
      get () {
        return this.rolesList[`${this.view.replace(/([a-z])([A-Z])/g, '$1_$2').toLowerCase()}_roles`]
      },
      set (value) {
        this.$set(this.rolesList, `${this.view.replace(/([a-z])([A-Z])/g, '$1_$2').toLowerCase()}_roles`, value)
      }
    },

    organizationList () {
      return this.rolesList.copyright_organization_roles.filter(item => !item?._destroy)
    },

    copyrightHolderList () {
      return this.rolesList.copyright_holder_roles.filter(item => !item?._destroy)
    },

    copyrightHolderOptions () {
      return ['person', 'organization'].map(label => {
        const count = [].concat(this.rolesList.copyright_organization_roles, this.copyrightHolderList).filter(item => item.agent_type === label).length
        return label + (count ? ` (${count})` : '')
      })
    }
  },

  data () {
    return {
      view: undefined,
      licenses: [],
      smartSelectorList: [],
      roleTypes: [],
      urlList: `${this.url}/${this.type}s.json`,
      rolesList: {
        creator_roles: [],
        owner_roles: [],
        editor_roles: [],
        copyright_holder_roles: [],
        copyright_organization_roles: []
      },
      attribution: this.newAttribution(),
      copyrightHolderType: 0
    }
  },

  watch: {
    list(newVal) {
      if (newVal.length) {
        this.setAttribution(newVal[0])
      }
    }
  },

  mounted () {
    this.getList('/attributions/licenses').then(response => {
      this.licenses = Object.keys(response.body).map(key => ({
        key: key,
        label: response.body[key]
      }))

      this.licenses.push({
        label: '-- None --',
        key: null
      })
    })

    this.getList('/attributions/role_types.json').then(response => {
      this.roleTypes = response.body
      this.smartSelectorList = this.roleTypes.map((role) => role.substring(11))
    })
  },

  methods: {
    setAttribution (attribution) {
      this.attribution.id = attribution.id
      this.attribution.copyright_year = attribution.copyright_year
      this.attribution.license = attribution.license
      this.rolesList.creator_roles = (attribution?.creator_roles ? attribution.creator_roles : [])
      this.rolesList.editor_roles = (attribution?.editor_roles ? attribution.editor_roles : [])
      this.rolesList.owner_roles = (attribution?.owner_roles ? attribution.owner_roles : [])
      this.rolesList.copyright_holder_roles = (attribution?.copyright_holder_roles ? attribution.copyright_holder_roles.filter(item => item.agent_type === 'person') : [])
      this.rolesList.copyright_organization_roles = (attribution?.copyright_holder_roles ? attribution.copyright_holder_roles.filter(item => item.agent_type === 'organization').map(item => { item.object_tag = item.organization.object_tag; return item }) : [])
    },

    newAttribution () {
      return {
        id: undefined,
        copyright_year: undefined,
        license: null,
        annotated_global_entity: this.globalId,
        roles_attributes: []
      }
    },

    createNew () {
      this.setRolesAttributes()
      this.create('/attributions', { attribution: this.attribution }).then(response => {
        this.setAttribution(response.body)
        TW.workbench.alert.create('Attribution was successfully created.', 'notice')
      })
    },

    updateAttribution () {
      this.setRolesAttributes()
      if (!this.validateFields) {
        this.attribution._destroy = true
        this.destroy(`/${this.type}s/${this.attribution.id}`, this.attribution).then(response => {
          this.removeFromList(this.attribution.id)
          TW.workbench.alert.create('Attribution was successfully destroyed.', 'notice')
          this.attribution = this.newAttribution()
        })
      } else {
        this.update(`/attributions/${this.attribution.id}.json`, { attribution: this.attribution }).then(response => {
          this.setAttribution(response.body)
          TW.workbench.alert.create('Attribution was successfully updated.', 'notice')
        })
      }
    },

    setRolesAttributes () {
      this.updateIndex()
      this.attribution.roles_attributes = [].concat.apply([], Object.values(this.rolesList))
    },

    updateIndex() {
      let lengthArrays = 0
      for (const key in this.rolesList) {
        this.rolesList[key] = this.rolesList[key].map((item, index) => {
          item.position = (index + 1) + lengthArrays
          return item
        })
        lengthArrays = lengthArrays + this.rolesList[key].length
      }
    },

    addOrganization (organization) {
      this.rolesList.copyright_organization_roles.push({
        organization_id: organization.id,
        type: 'AttributionCopyrightHolder',
        object_tag: organization?.object_tag ? organization.object_tag : organization.label
      })
    },

    removeOrganization (organization) {
      const index = organization?.id ?
        this.rolesList.copyright_organization_roles.findIndex(item => item?.id === organization.id) :
        this.rolesList.copyright_organization_roles.findIndex(item => item?.organization_id === organization.organization_id)

      if (this.rolesList.copyright_organization_roles[index]['id']) {
        this.rolesList.copyright_organization_roles[index]['_destroy'] = true
      } else {
        this.rolesList.copyright_organization_roles.splice(index, 1)
      }
    },

    roleExist (id) {
      return this.roleList.find(role => !role?._destroy && (role.person_id === id || role?.person?.id === id))
    },

    addRole (role) {
      if (!this.roleExist(role.id)) {
        this.roleList.push({
          first_name: role.first_name,
          last_name: role.last_name,
          person_id: role.id,
          type: this.roleSelected
        })
      }
    },
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
        width: 120px;
      }
    }
  }
</style>
