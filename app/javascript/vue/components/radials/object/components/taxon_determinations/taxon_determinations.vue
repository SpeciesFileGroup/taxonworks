<template>
  <div>
    <h3>Determinations</h3>
    <div id="taxon-determination-digitize">
      <fieldset
        class="separate-bottom">
        <legend>OTU</legend>
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
          class="middle">
          <span
            class="margin-small-right"
            v-html="selectedOtu.object_tag"/>
          <span
            class="button-circle button-default btn-undo"
            @click="selectedOtu = undefined"/>
        </p>
      </fieldset>
      <fieldset>
        <legend>Determiner</legend>
        <smart-selector
          model="people"
          target="Determiner"
          :autocomplete="false"
          @selected="addRole">
          <role-picker
            class="margin-medium-top"
            roleType="Determiner"
            v-model="taxon_determination.roles_attributes"/>
        </smart-selector>
      </fieldset>
      <div class="horizontal-left-content date-fields separate-bottom separate-top align-end">
        <date-fields
          v-model:year="taxon_determination.year_made"
          v-model:month="taxon_determination.month_made"
          v-model:day="taxon_determination.day_made"
        />
        <button
          type="button"
          class="button normal-input button-default separate-left separate-right"
          @click="setActualDate">
          Now
        </button>
      </div>
      <button
        type="button"
        id="determination-add-button"
        :disabled="!taxon_determination.otu_id"
        class="button normal-input button-submit separate-top"
        @click="addDetermination">Add</button>
      <display-list
        :list="list"
        @delete="removeTaxonDetermination"
        :radial-object="true"
        set-key="otu_id"
        label="object_tag"/>
    </div>
  </div>
</template>

<script>

import RolePicker from 'components/role_picker.vue'
import DisplayList from 'components/displayList.vue'
import SmartSelector from 'components/ui/SmartSelector'
import CRUD from '../../request/crud.js'
import AnnotatorExtend from '../annotatorExtend.js'
import DateFields from 'components/ui/Date/DateFields.vue'

export default {
  mixins: [CRUD, AnnotatorExtend],
  components: {
    SmartSelector,
    RolePicker,
    DisplayList,
    DateFields
  },
  data () {
    return {
      taxon_determination: this.newDetermination(),
      selectedOtu: undefined
    }
  },
  methods: {
    setOtu (otu) {
      this.taxon_determination.otu_id = otu.id
      this.selectedOtu = otu
    },
    newDetermination () {
      return {
        biological_collection_object_id: this.metadata.object_id,
        otu_id: undefined,
        year_made: undefined,
        month_made: undefined,
        day_made: undefined,
        roles_attributes: [],
      }
    },
    createPerson (person, roleType) {
      return {
        first_name: person.first_name,
        last_name: person.last_name,
        person_id: person.id,
        type: roleType
      }
    },
    roleExist(id) {
      return (this.taxon_determination.roles_attributes.find((role) => {
        return !role.hasOwnProperty('_destroy') && role.person_id == id
      }) ? true : false)
    },
    addRole(role) {
      if(!this.roleExist(role.id)) {
        this.taxon_determination.roles_attributes.push(this.createPerson(role, 'Determiner'))
      }
    },
    addDetermination() {
      if(this.list.find((determination) => { return determination.otu_id === this.taxonDetermination.otu_id && (determination.year_made === this.year) })) { return }
      
      this.create(`/taxon_determinations.json`, { taxon_determination: this.taxon_determination }).then(response => {
        TW.workbench.alert.create('Taxon determination was successfully created.', 'notice')
        this.list.push(response.body)
      })
    },
    removeTaxonDetermination(determination) {
      this.removeItem(determination).then(response => {
        TW.workbench.alert.create('Taxon determination was successfully destroyed.', 'notice')        
      })
    },
    setActualDate() {
      let today = new Date()
      this.taxon_determination.day_made = today.getDate()
      this.taxon_determination.month_made = today.getMonth() + 1
      this.taxon_determination.year_made = today.getFullYear()
    }
  }
}
</script>