<template>
  <fieldset>
    <legend>Taxon determination</legend>
    <span>Otu</span>
    <smart-selector
      class="margin-medium-bottom"
      model="otus"
      pin-section="Otus"
      pin-type="Otu"
      target="TaxonDetermination"
      @selected="setOtu"
    />
    <p
      v-if="selectedOtu"
      class="middle"
    >
      <span
        class="margin-small-right"
        v-html="selectedOtu.object_tag"
      />
      <span
        class="button-circle button-default btn-undo"
        @click="selectedOtu = undefined"
      />
    </p>
    <span>Determiner</span>
    <smart-selector
      model="people"
      target="Determiner"
      :autocomplete="false"
      @selected="addRole"
    >
      <role-picker
        class="margin-medium-top"
        role-type="Determiner"
        v-model="taxon_determination.roles_attributes"
      />
    </smart-selector>
    <div class="horizontal-left-content date-fields separate-bottom separate-top align-end">
      <date-fields
        v-model:year="taxon_determination.year_made"
        v-model:month="taxon_determination.month_made"
        v-model:day="taxon_determination.day_made"
      />
      <button
        type="button"
        class="button normal-input button-default separate-left separate-right"
        @click="setActualDate"
      >
        Now
      </button>
    </div>
    <button
      type="button"
      id="determination-add-button"
      :disabled="!selectedOtu"
      class="button normal-input button-submit separate-top"
      @click="addDetermination"
    >
      Add
    </button>
    <list-component
      :list="collectionObject.taxon_determinations_attributes"
      @delete="removeTaxonDetermination"
      set-key="otu_id"
      label="object_tag"
    />
  </fieldset>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector'
import RolePicker from 'components/role_picker'
import CreatePerson from '../../helpers/CreatePerson'
import DateFields from 'components/ui/Date/DateFields.vue'

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import ListComponent from 'components/displayList'
import SharedComponent from '../shared/lock.js'

export default {
  mixins: [SharedComponent],

  components: {
    ListComponent,
    SmartSelector,
    RolePicker,
    DateFields
  },

  computed: {
    collectionObject: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionObject]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectionObject, value)
      }
    }
  },

  data () {
    return {
      taxon_determination: undefined,
      selectedOtu: undefined
    }
  },

  created () {
    this.resetDetermination()
  },

  methods: {
    setActualDate () {
      const today = new Date()
      this.taxon_determination.day_made = today.getDate()
      this.taxon_determination.month_made = today.getMonth() + 1
      this.taxon_determination.year_made = today.getFullYear()
    },

    roleExist (id) {
      return (!!this.taxon_determination.roles_attributes.find(role => !role.hasOwnProperty('_destroy') && role.hasOwnProperty('person_id') && role.person_id == id))
    },

    addRole (role) {
      if (!this.roleExist(role.id)) {
        this.taxon_determination.roles_attributes.push(CreatePerson(role, 'Determiner'))
      }
    },

    addDetermination () {
      if (this.collectionObject.taxon_determinations_attributes.find((determination) => determination.otu_id == this.taxon_determination.otu_id)) { return }
      this.taxon_determination.object_tag = this.selectedOtu.object_tag
      this.collectionObject.taxon_determinations_attributes.push(this.taxon_determination)
      this.selectedOtu = undefined

      this.resetDetermination()
    },

    resetDetermination () {
      this.taxon_determination = {
        otu_id: undefined,
        year_made: undefined,
        month_made: undefined,
        day_made: undefined,
        roles_attributes: []
      }
    },

    setOtu (otu) {
      this.taxon_determination.otu_id = otu.id
      this.selectedOtu = otu
    },

    removeTaxonDetermination (determination) {
      const index = this.collectionObject.taxon_determinations_attributes.findIndex(item => JSON.stringify(item) === JSON.stringify(determination))

      this.collectionObject.taxon_determinations_attributes.splice(index, 1)
    }
  }
}
</script>
<style lang="scss" scoped>
  .date-fields {
    input {
      width:60px;
    }
    label {
      display: block;
    }
  }
</style>
