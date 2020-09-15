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
    <div class="horizontal-left-content date-fields separate-bottom separate-top">
      <div class="separate-right">
        <label>Year</label>
        <input
          type="text"
          v-model="taxon_determination.year_made"
        >
      </div>
      <div class="separate-right separate-left">
        <label>Month</label>
        <input
          type="text"
          v-model="taxon_determination.month_made"
        >
      </div>
      <div class="separate-left">
        <label>Day</label>
        <input
          type="text"
          v-model="taxon_determination.day_made"
        >
      </div>
      <div>
        <label>&nbsp</label>
        <div class="align-start">
          <button
            type="button"
            class="button normal-input button-default separate-left separate-right"
            @click="setActualDate"
          >
            Now
          </button>
        </div>
      </div>
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

import SmartSelector from 'components/smartSelector'
import RolePicker from 'components/role_picker'
import CreatePerson from '../../helpers/CreatePerson'

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import ListComponent from 'components/displayList'
import SharedComponent from '../shared/lock.js'

export default {
  mixins: [SharedComponent],
  components: {
    ListComponent,
    SmartSelector,
    RolePicker
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
      return (!!this.taxon_determination.roles_attributes.find((role) => {
        return !role.hasOwnProperty('_destroy') && role.hasOwnProperty('person_id') && role.person_id == id
      }))
    },
    addRole (role) {
      if (!this.roleExist(role.id)) {
        this.taxon_determination.roles_attributes.push(CreatePerson(role, 'Determiner'))
      }
    },
    addDetermination () {
      if (this.collectionObject.taxon_determinations_attributes.find((determination) => { return determination.otu_id == this.taxon_determination.otu_id })) { return }
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
      const index = this.collectionObject.taxon_determinations_attributes.findIndex(item => {
        return JSON.stringify(item) === JSON.stringify(determination)
      })

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
