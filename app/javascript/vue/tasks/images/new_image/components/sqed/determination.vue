<template>
  <div>
    <h3>Taxon determination</h3>
    <fieldset
      class="separate-bottom">
      <legend>OTU</legend>
      <div class="horizontal-left-content separate-bottom align-start">
        <smart-selector
          class="margin-medium-bottom full_width"
          model="otus"
          input-id="determination-otu-autocomplete"
          pin-section="Otus"
          pin-type="Otu"
          :autocomplete="false"
          :otu-picker="true"
          :filter-ids="taxonDetermination.otu_id"
          target="TaxonDetermination"
          @selected="setOtu"
        />
      </div>
      <div>
        <p
          v-if="taxonDetermination.object_tag"
          class="middle"
        >
          <span
            class="margin-small-right"
            v-html="taxonDetermination.object_tag"
          />
          <span
            class="button-circle button-default btn-undo"
            @click="setOtu()"
          />
        </p>
      </div>
    </fieldset>

    <fieldset>
      <legend>Determiner</legend>
      <div class="horizontal-left-content separate-bottom align-start">
        <smart-selector
          class="full_width"
          model="people"
          target="Determiner"
          :autocomplete="false"
          :filter-ids="taxonDetermination.roles_attributes.map(item => item.person_id)"
          @onTabSelected="view = $event"
          @selected="addRole">
          <template #header>
            <role-picker
              class="role-picker"
              :autofocus="false"
              hidden-list
              ref="rolepicker"
              role-type="Determiner"
              v-model="taxonDetermination.roles_attributes"/>
          </template>
          <role-picker
            class="role-picker"
            :autofocus="false"
            :create-form="false"
            role-type="Determiner"
            v-model="taxonDetermination.roles_attributes"/>
        </smart-selector>
      </div>
    </fieldset>

    <div class="horizontal-left-content date-fields separate-bottom separate-top align-end">
      <date-fields
        v-model:year="taxonDetermination.year_made"
        v-model:month="taxonDetermination.month_made"
        v-model:day="taxonDetermination.day_made"
      />
      <button
        type="button"
        class="button normal-input button-default separate-left"
        @click="setActualDate"
      >
        Now
      </button>
    </div>
    <button
      type="button"
      :disabled="!taxonDetermination.otu_id"
      class="button normal-input button-submit separate-top"
      @click="addDetermination"
    >
      Add
    </button>
    <div class="flex-separate margin-medium-top">
      <span>Determinations</span>
      <lock-component v-model="settings.lock.taxon_determinations"/>
    </div>
    <display-list
      :list="list"
      @delete="removeTaxonDetermination"
      set-key="otu_id"
      label="object_tag"
    />
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations'
import SmartSelector from 'components/ui/SmartSelector.vue'
import RolePicker from 'components/role_picker.vue'
import DisplayList from 'components/displayList.vue'
import CreatePerson from '../../helpers/createPerson.js'
import makeTaxonDetermination from '../../const/makeTaxonDetermination'
import LockComponent from 'components/ui/VLock/index.vue'
import DateFields from 'components/ui/Date/DateFields.vue'

export default {
  components: {
    SmartSelector,
    RolePicker,
    DisplayList,
    LockComponent,
    DateFields
  },

  computed: {
    list: {
      get () {
        return this.$store.getters[GetterNames.GetTaxonDeterminations]
      },
      set (value) {
        this.$store.commit(MutationNames.SetTaxonDetermination, value)
      }
    },

    taxonDetermination: {
      get () {
        return this.$store.getters[GetterNames.GetTaxonDetermination]
      },
      set (value) {
        this.$store.commit(MutationNames.SetTaxonDetermination, value)
      }
    },

    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    }
  },

  methods: {
    roleExist (id) {
      return !!this.taxonDetermination.roles_attributes.find((role) => !role?._destroy && role?.person && role.person.id === id)
    },

    addRole (role) {
      if (!this.roleExist(role.id)) {
        this.taxonDetermination.roles_attributes.push(CreatePerson(role, 'Determiner'))
      }
    },

    addDetermination () {
      if (this.list.find(determination => determination.otu_id === this.taxonDetermination.otu_id)) return
      this.list.push(this.taxonDetermination)
      this.taxonDetermination = makeTaxonDetermination()
    },

    removeTaxonDetermination (determination) {
      this.list.splice(this.list.findIndex(item => item.otu_id === determination.id), 1)
    },

    setActualDate () {
      const today = new Date()
      this.taxonDetermination.day_made = today.getDate()
      this.taxonDetermination.month_made = today.getMonth() + 1
      this.taxonDetermination.year_made = today.getFullYear()
    },

    setOtu (otu) {
      this.taxonDetermination.otu_id = otu?.id
      this.taxonDetermination.object_tag = otu?.object_tag
    }
  }
}
</script>

<style lang="scss" scoped>
    label {
      display: block;
    }
    .date-fields {
      input {
        max-width: 60px;
      }
    }
    .smart-list {
      margin-bottom: 4px;
    }
</style>
