<template>
  <div class="panel content panel-section">
    <div>
      <h2>{{ title }}</h2>
    </div>
    <div class="flexbox">
      <div class="separate-right">
        <smart-selector
          class="separate-bottom"
          :options="options"
          v-model="view"
        />
        <role-picker
          v-if="view == 'someone else'"
          v-model="roles_attributes"
          :role-type="roleType"
        />
        <autocomplete
          v-else
          placeholder="Select an organization"
          url="/organizations/autocomplete"
          param="term"
          @get-item="setOrganization"
          label="label_html"
        />
      </div>
      <div class="separate-left">
        <label>
          Year of copyright
          <input
            type="number"
            v-model="year"
          >
        </label>
      </div>
    </div>
  </div>
</template>

<script>

import SmartSelector from 'components/switch'
import RolePicker from 'components/role_picker'
import Autocomplete from 'components/ui/Autocomplete'
import { GetterNames } from '../store/getters/getters.js'
import { MutationNames } from '../store/mutations/mutations.js'

export default {
  components: {
    SmartSelector,
    RolePicker,
    Autocomplete
  },

  props: {
    title: {
      type: String,
      required: true
    },
    roleType: {
      type: String,
      required: true
    }
  },

  computed: {
    roles_attributes: {
      get () {
        return this.$store.getters[GetterNames.GetPeople].copyrightHolder
      },
      set (value) {
        this.$store.commit(MutationNames.SetCopyrightHolder, value)
      }
    },

    year: {
      get () {
        return this.$store.getters[GetterNames.GetYearCopyright]
      },
      set (value) {
        this.$store.commit(MutationNames.SetYearCopyright, value)
      }
    }
  },

  data () {
    return {
      options: ['someone else', 'an organization'],
      view: 'someone else'
    }
  },

  methods: {
    setOrganization (organization) {
      this.roles_attributes = [{
        type: this.roleType,
        label: organization.label,
        organization_id: organization.id
      }]
    }
  }
}
</script>
<style lang="scss">
  .switch-radio {
    label {
      width: 100%;
    }
  }
</style>
