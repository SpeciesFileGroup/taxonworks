<template>
  <block-layout :warning="!taxonDetermination.id">
    <div slot="header">
      <h3>Determinations</h3>
    </div>
    <div
      slot="body"
      id="taxon-determination-digitize">
      <fieldset
        class="separate-bottom">
        <legend>OTU</legend>
        <div class="horizontal-left-content separate-bottom align-start">
          <smart-selector
            class="margin-medium-bottom"
            model="otus"
            input-id="determination-otu-autocomplete"
            pin-section="Otus"
            pin-type="Otu"
            :autocomplete="false"
            :otu-picker="true"
            target="TaxonDetermination"
            @selected="setOtu"
          />
          <lock-component
            class="margin-small-left"
            v-model="locked.taxon_determination.otu_id"/>
        </div>
        <div
          v-if="otuSelected"
          class="horizontal-left-content">
          <p v-html="otuSelected"/>
          <span
            class="circle-button button-default btn-undo"
            @click="otuId = undefined; otuSelected = undefined"/>
        </div>
      </fieldset>
      <fieldset>
        <legend>Determiner</legend>
        <div class="horizontal-left-content separate-bottom align-start">
          <smart-selector
            model="people"
            target="Determiner"
            :autocomplete="false"
            @selected="addRole">
            <role-picker
              :autofocus="false"
              ref="rolepicker"
              role-type="Determiner"
              v-model="roles"/>
          </smart-selector>
          <lock-component
            class="margin-small-left"
            v-model="locked.taxon_determination.roles_attributes"/>
        </div>
      </fieldset>
      <div class="horizontal-left-content date-fields separate-bottom separate-top">
        <div class="separate-left">
          <label>Day</label>
          <input
            type="number"
            v-model="day">
        </div>
        <div class="separate-right separate-left">
          <label>Month</label>
          <input
            type="number"
            v-model="month">
        </div>
        <div class="separate-right">
          <label>Year</label>
          <input
            type="number"
            v-model="year">
        </div>
        <div>
          <label>&nbsp</label>
          <div class="align-start">
            <button
              type="button"
              class="button normal-input button-default separate-left separate-right"
              @click="setActualDate">
              Now
            </button>
            <lock-component v-model="locked.taxon_determination.dates"/>
          </div>
        </div>
      </div>
      <button
        type="button"
        id="determination-add-button"
        :disabled="!otuId"
        class="button normal-input button-submit separate-top"
        @click="addDetermination">Add</button>
      <draggable
        class="table-entrys-list"
        element="ul"
        v-model="list"
        @end="updatePosition">
        <li
          class="list-complete-item flex-separate middle"
          v-for="(item, index) in list">
          <span v-html="item.object_tag"/>
          <div class="horizontal-left-content">
            <radial-annotator
              v-if="item.hasOwnProperty('global_id')"
              :global-id="item.global_id"/>
            <span
              class="circle-button btn-delete"
              @click="removeTaxonDetermination(item)"/>
          </div>
        </li>
      </draggable>
    </div>
  </block-layout>
</template>

<script>

import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'
import { ActionNames } from '../../store/actions/actions'
import { GetOtu } from '../../request/resources.js'

import SmartSelector from 'components/smartSelector.vue'
import RolePicker from 'components/role_picker.vue'
import OtuPicker from 'components/otu/otu_picker/otu_picker.vue'
import BlockLayout from 'components/blockLayout.vue'
import CreatePerson from '../../helpers/createPerson.js'
import LockComponent from 'components/lock'
import Draggable from 'vuedraggable'
import RadialAnnotator from 'components/radials/annotator/annotator'


export default {
  components: {
    SmartSelector,
    RolePicker,
    OtuPicker,
    BlockLayout,
    LockComponent,
    Draggable,
    RadialAnnotator
  },
  computed: {
    collectionObject() {
      return this.$store.getters[GetterNames.GetCollectionObject]
    },
    taxonDetermination() {
      return this.$store.getters[GetterNames.GetTaxonDetermination]
    },
    otu: {
      get() {
        return this.$store.getters[GetterNames.GetTmpData].otu
      },
      set(value) {
        this.$store.commit(MutationNames.SetTmpDataOtu, value)
      }
    },
    locked: {
      get() {
        return this.$store.getters[GetterNames.GetLocked]
      },
      set(value) {
        this.$store.commit(MutationNames.SetLocked, value)
      }
    },
    otuId: {
      get() {
        return this.$store.getters[GetterNames.GetTaxonDetermination].otu_id
      },
      set(value) {
        this.$store.commit(MutationNames.SetTaxonDeterminationOtuId, value)
      }
    },
    day: {
      get() {
        return this.$store.getters[GetterNames.GetTaxonDetermination].day_made
      },
      set(value) {
        this.$store.commit(MutationNames.SetTaxonDeterminationDay, value)
      }
    },
    month: {
      get() {
        return this.$store.getters[GetterNames.GetTaxonDetermination].month_made
      },
      set(value) {
        this.$store.commit(MutationNames.SetTaxonDeterminationMonth, value)
      }
    },
    year: {
      get() {
        return this.$store.getters[GetterNames.GetTaxonDetermination].year_made
      },
      set(value) {
        this.$store.commit(MutationNames.SetTaxonDeterminationYear, value)
      }
    },
    roles: {
      get() {
        return this.$store.getters[GetterNames.GetTaxonDetermination].roles_attributes
      },
      set(value) {
        this.$store.commit(MutationNames.SetTaxonDeterminationRoles, value)
      }
    },
    list: {
      get () {
      return this.$store.getters[GetterNames.GetTaxonDeterminations]
      },
      set (value) {
        this.$store.commit(MutationNames.SetTaxonDeterminations, value)
      }
    }
  },
  data() {
    return {
      view: 'new/Search',
      viewDeterminer: 'new/Search',
      options: [],
      optionsDeterminer: ['Quick', 'Recent', 'Pinboard', 'new/Search'],
      lists: [],
      listsDeterminator: [],
      otuSelected: undefined
    }
  },
  watch: {
    collectionObject(newVal) {
      this.$refs.rolepicker.reset()
    },
    otuId(newVal) {
      if(newVal) {
        GetOtu(newVal).then(response => {
          this.otuSelected = response.object_tag
          this.otu = response
        })
      }
      else {
        this.otu = undefined
        this.otuSelected = undefined
      }
    }
  },
  mounted() {
    let urlParams = new URLSearchParams(window.location.search)
    let otuId = urlParams.get('otu_id')

    if (/^\d+$/.test(otuId)) {
      this.otuId = otuId
    }
  },
  methods: {
    roleExist (id) {
      return (this.roles.find((role) => {
        return !role.hasOwnProperty('_destroy') && role.person_id == id
      }) ? true : false)
    },
    addRole (role) {
      if(!this.roleExist(role.id)) {
        this.roles.push(CreatePerson(role, 'Determiner'))
      }
    },
    saveDetermination () {
      this.$store.dispatch(ActionNames.SaveDetermination)
    },
    addDetermination () {
      if (this.list.find((determination) => {
        return determination.otu_id === this.taxonDetermination.otu_id && (determination.year_made === this.year) 
      })
      ) { return }
      this.taxonDetermination.object_tag = `${this.otuSelected}`
      this.$store.commit(MutationNames.AddTaxonDetermination, this.taxonDetermination)
      this.$store.commit(MutationNames.NewTaxonDetermination)
    },
    removeTaxonDetermination (determination) {
      this.$store.dispatch(ActionNames.RemoveTaxonDetermination, determination)
    },
    setActualDate () {
      const today = new Date()
      this.day = today.getDate()
      this.month = today.getMonth() + 1
      this.year = today.getFullYear()
    },
    updatePosition () {
      for(let i = 0; i < this.list.length; i++) {
        this.list[i].position = (i + 1)
      }
    },
    setOtu (otu) {
      this.otuId = otu.id
      this.otuSelected = otu.object_tag
    }
  }
}
</script>

<style lang="scss">
  #taxon-determination-digitize {
    label {
      display: block;
    }
    .date-fields {
      input {
        max-width: 80px;
      }
    }
      .vue-autocomplete-input {
        max-width: 150px;
      }
    
  }
</style>
