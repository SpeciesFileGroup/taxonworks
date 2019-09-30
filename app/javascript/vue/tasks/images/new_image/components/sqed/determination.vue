<template>
  <fieldset>
    <legend>Taxon determination</legend>
    <fieldset
      class="separate-bottom"
    >
      <legend>OTU</legend>
      <div class="horizontal-left-content separate-bottom middle">
        <smart-selector
          v-model="view"
          class="separate-right"
          name="otu-determination"
          :options="options" 
        />
      </div>
      <template>
        <div 
          v-if="view == 'new/Search' && !taxonDetermination.otu_id"
          class="horizontal-left-content"
        >
          <otu-picker
            @getItem="taxonDetermination.otu_id = $event.id; otuSelected = ($event.hasOwnProperty('label_html') ? $event.label_html : $event.object_tag)" 
          /> 
          <pin-default
            class="separate-left"
            section="Otus"
            @getId="taxonDetermination.otu_id = $event"
            type="Otu"
          />
        </div>
        <ul
          v-else
          class="no_bullets"
        >
          <li
            v-for="item in lists[view]"
            :key="item.id"
            :value="item.id"
            class="smart-list"
          >
            <label>
              <input
                v-model="taxonDetermination.otu_id"
                @click="otuSelected = item.object_tag"
                :value="item.id"
                type="radio"
              >
              <span v-html="item.object_tag" />
            </label>
          </li>
        </ul>
      </template>
      <div
        v-if="otuSelected"
        class="horizontal-left-content"
      >
        <p v-html="otuSelected" />
        <span
          class="circle-button button-default btn-undo"
          @click="taxonDetermination.otu_id = undefined; otuSelected = undefined"
        />
      </div>
    </fieldset>
    <fieldset>
      <legend>Determiner</legend>
      <div class="horizontal-left-content separate-bottom middle">
        <smart-selector
          v-model="viewDeterminer"
          class="separate-right"
          name="determiner"
          :options="optionsDeterminer" 
        />
      </div>
      <template>
        <div
          v-if="viewDeterminer != 'new/Search'"
          class="separate-bottom"
        >
          <ul class="no_bullets">
            <li
              v-for="item in listsDeterminator[viewDeterminer]"
              v-if="!roleExist(item.id)"
              :key="item.id"
              :value="item.id"
            >
              <label>
                <input
                  @click="addRole(item)"
                  :value="item.id"
                  type="radio"
                >
                <span v-html="item.object_tag" />
              </label>
            </li>
          </ul>
        </div>
        <role-picker
          :autofocus="false" 
          role-type="Determiner"
          v-model="taxonDetermination.roles_attributes"
        />
      </template>
    </fieldset>
    <div class="horizontal-left-content date-fields separate-bottom separate-top">
      <div class="separate-right">
        <label>Year</label>
        <input
          type="text"
          v-model="taxonDetermination.year_made"
        >
      </div>
      <div class="separate-right separate-left">
        <label>Month</label>
        <input
          type="text"
          v-model="taxonDetermination.month_made"
        >
      </div>
      <div class="separate-left">
        <label>Day</label>
        <input
          type="text"
          v-model="taxonDetermination.day_made"
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
      :disabled="!taxonDetermination.otu_id"
      class="button normal-input button-submit separate-top"
      @click="addDetermination"
    >
      Add
    </button>
    <display-list
      :list="list"
      @delete="removeTaxonDetermination"
      set-key="otu_id"
      label="object_tag" 
    />
  </fieldset>
</template>

<script>

import SmartSelector from 'components/switch.vue'
import PinDefault from 'components/getDefaultPin.vue'
import RolePicker from 'components/role_picker.vue'
import OtuPicker from 'components/otu/otu_picker/otu_picker.vue'
import { GetterNames } from '../../store/getters/getters.js'
import DisplayList from 'components/displayList.vue'
import CreatePerson from '../../helpers/createPerson.js'
import orderSmartSelector from 'helpers/smartSelector/orderSmartSelector.js'
import selectFirstSmartOption from 'helpers/smartSelector/selectFirstSmartOption'
import { GetOtuSmartSelector, GetTaxonDeterminatorSmartSelector } from '../../request/resources.js'


export default {
  components: {
    SmartSelector,
    RolePicker,
    OtuPicker,
    DisplayList,
    PinDefault,
  },
  computed: {
    list() {
      return this.$store.getters[GetterNames.GetTaxonDeterminations]
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
      otuSelected: undefined,
      taxonDetermination: {
        biological_collection_object_id: undefined,
        roles_attributes: [],
        otu_id: undefined,
        day_made: undefined,
        month_made: undefined,
        year_made: undefined
      }
    }
  },
  mounted() {
    GetOtuSmartSelector().then(response => {
      this.options = orderSmartSelector(Object.keys(response.body))
      this.options.push('new/Search')
      this.lists = response.body
      let view = selectFirstSmartOption(response.body, this.options)
      this.view = view ? view : 'new/Search'
    })
    GetTaxonDeterminatorSmartSelector().then(response => {
      this.optionsDeterminer = orderSmartSelector(Object.keys(response.body))
      this.optionsDeterminer.push('new/Search')
      this.listsDeterminator = response.body
      let view = selectFirstSmartOption(response.body, this.optionsDeterminer)
      this.viewDeterminer = view ? view : 'new/Search'
    })
  },
  methods: {
    roleExist(id) {
      return (this.taxonDetermination.roles_attributes.find((role) => {
        return !role.hasOwnProperty('_destroy') && role.hasOwnProperty('person') && role.person.id == id
      }) ? true : false)
    },
    addRole(role) {
      if(!this.roleExist(role.id)) {
        this.taxonDetermination.roles_attributes.push(CreatePerson(role, 'Determiner'))
      }
    },
    newTaxonDetermination() {
      this.taxonDetermination = {
        biological_collection_object_id: undefined,
        roles_attributes: [],
        otu_id: undefined,
        day_made: undefined,
        month_made: undefined,
        year_made: undefined
      }
    },
    addDetermination() {
      if(this.list.find((determination) => { return determination.otu_id == this.taxonDetermination.otu_id })) { return }
      this.taxonDetermination.object_tag = `${this.otuSelected}`
      this.list.push(this.taxonDetermination)
      this.newTaxonDetermination()
    },
    removeTaxonDetermination(determination) {
      this.list.splice(this.list.findIndex(item => {
        return item.otu_id == determination.id
      }), 1)
    },
    setActualDate() {
      let today = new Date()
      this.taxonDetermination.day_made = today.getDate()
      this.taxonDetermination.month_made = today.getMonth() + 1
      this.taxonDetermination.year_made = today.getFullYear()
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
