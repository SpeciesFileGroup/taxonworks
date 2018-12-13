<template>
  <block-layout>
    <div slot="header">
      <h3>Determinations</h3>
    </div>
    <div slot="body">
      <fieldset>
        <legend>OTU</legend>
        <smart-selector
          v-model="view"
          class="separate-bottom"
          name="otu-determination"
          :options="options"/>
        <template>
          <otu-picker
            v-if="view == 'new/Search'"
            @getItem="otu = $event.id; otuSelected = $event.label_html"/> 
          <ul
            v-else
            class="no_bullets">
            <li
              v-for="item in lists[view]"
              :key="item.id"
              :value="item.id">
              <label
                @click="otuSelected = item.label_html">
                <input
                  v-model="otu"
                  :value="item.id"
                  type="radio">
                <span v-html="item.object_tag"/>
              </label>
            </li>
          </ul>
        </template>
        <p v-html="otuSelected"/>
      </fieldset>
      <fieldset>
        <legend>Determiner</legend>
        <smart-selector
          v-model="viewDeterminer"
          class="separate-bottom"
          name="determiner"
          :options="optionsDeterminer"/>
        <role-picker
          :autofocus="false" 
          role-type="Determiner"
          v-model="roles"/>
        <div class="horizontal-left-content date-fields separate-bottom">
          <div class="separate-right">
            <label>Year</label>
            <input
              type="text"
              v-model="year">
          </div>
          <div class="separate-right separate-left">
            <label>Month</label>
            <input
              type="text"
              v-model="month">
          </div>
          <div class="separate-left">
            <label>Day</label>
            <input
              type="text"
              v-model="day">
          </div>
          <div>
            <label>&nbsp</label>
            <button
              type="button"
              class="button normal-input button-default separate-left"
              @click="setActualDate">
              Now
            </button>
          </div>
        </div>
      </fieldset>
      <button
        type="button"
        class="button normal-input button-submit separate-top"
        @click="SaveMethod">Save</button>
      <display-list
        :list="list"
        label="object_tag"/>
    </div>
  </block-layout>
</template>

<script>

import SmartSelector from 'components/switch.vue'
import RolePicker from 'components/role_picker.vue'
import OtuPicker from 'components/otu/otu_picker/otu_picker.vue'
import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'
import BlockLayout from 'components/blockLayout.vue'
import { ActionNames } from '../../store/actions/actions';
import DisplayList from 'components/displayList.vue'
import { GetOtu, GetOtuSmartSelector, GetTaxonDeterminatorSmartSelector } from '../../request/resources.js'

export default {
  components: {
    SmartSelector,
    RolePicker,
    OtuPicker,
    BlockLayout,
    DisplayList
  },
  computed: {
    otu: {
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
        return this.$store.getters[GetterNames.GetTaxonDetermination.roles_attributes]
      },
      set(value) {
        this.$store.commit(MutationNames.SetTaxonDeterminationRoles, value)
      }
    },
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
      otuSelected: undefined
    }
  },
  watch: {
    otu(newVal) {
      if(newVal) {
        GetOtu(newVal).then(response => {
          this.otuSelected = response.object_tag
        })
      }
      else {
        this.otuSelected = undefined
      }
    }
  },
  mounted() {
    GetOtuSmartSelector().then(response => {
      this.options = Object.keys(response)
      this.options.push('new/Search')
      this.lists = response
    })
    GetTaxonDeterminatorSmartSelector().then(response => {
      this.optionsDeterminer = Object.keys(response)
      this.optionsDeterminer.push('new/Search')
      this.listsDeterminator = response      
    })
  },
  methods: {
    SaveMethod() {
      this.$store.dispatch(ActionNames.SaveDetermination)
    },
    setActualDate() {
      let today = new Date()
      this.day = today.getDate()
      this.month = today.getMonth() + 1
      this.year = today.getFullYear()
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
</style>
