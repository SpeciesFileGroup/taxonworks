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
        v-model="attribution.roles_attributes"
        :filter-by-role="true"
        :role-type="roleSelected"/>
    </div>
    <div class="separate-top">
      <button
        type="button"
        @click="createNew"
        :disabled="!validateFields"
        class="button normal-input button-submit save-annotator-button">Save
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
      return this.attribution.license && this.attribution.copyright_year
    },
    roleSelected() {
      return this.roleTypes[this.smartSelectorList.findIndex((role) => { return role == this.view })]
    },
  },
  data() {
    return {
      view: undefined,
      licenses: [],
      smartSelectorList: [],
      roleTypes: [],
      attribution: {
        copyright_year: undefined,
        license: undefined,
        annotated_global_entity: this.globalId,
        roles_attributes: []
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
    createNew() {
      this.create('/attributions', { attribution: this.attribution }).then(response => {
        TW.workbench.alert.create('Attribution was successfully updated.', 'notice')
      })
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
