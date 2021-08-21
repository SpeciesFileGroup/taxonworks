<template>
  <div>
    <h3>Determinations</h3>
    <div id="taxon-determination-digitize">
      <fieldset
        class="separate-bottom">
        <legend>OTU</legend>
        <div class="horizontal-left-content separate-bottom align-start">
          <smart-selector
            class="margin-medium-bottom full_width"
            model="otus"
            ref="smartSelector"
            pin-section="Otus"
            pin-type="Otu"
            :autocomplete="false"
            :otu-picker="true"
            target="TaxonDetermination"
            @selected="setOtu"
          />
        </div>
        <div
          v-if="taxonDetermination.otuSelected"
          class="horizontal-left-content">
          <p v-html="taxonDetermination.otuSelected"/>
          <span
            class="circle-button button-default btn-undo"
            @click="taxonDetermination.otu_id = undefined; taxonDetermination.otuSelected = undefined"/>
        </div>
      </fieldset>
      <fieldset>
        <legend>Determiner</legend>
        <div class="horizontal-left-content separate-bottom align-start">
          <smart-selector
            class="full_width"
            ref="determinerSmartSelector"
            model="people"
            target="Determiner"
            :autocomplete="false"
            @selected="addRole">
            <template #header>
              <role-picker
                class="role-picker"
                :autofocus="false"
                :hidden-list="true"
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
      <div class="horizontal-left-content date-fields separate-bottom separate-top">
        <div class="separate-left">
          <label>Year</label>
          <input
            type="number"
            v-model="taxonDetermination.year_made">
        </div>
        <div class="separate-right separate-left">
          <label>Month</label>
          <input
            type="number"
            v-model="taxonDetermination.month_made">
        </div>
        <div class="separate-right">
          <label>Day</label>
          <input
            type="number"
            v-model="taxonDetermination.day_made">
        </div>
        <div>
          <label>&nbsp;</label>
          <div class="align-start">
            <button
              type="button"
              class="button normal-input button-default separate-left separate-right"
              @click="setActualDate">
              Now
            </button>
          </div>
        </div>
      </div>
      <button
        type="button"
        id="determination-add-button"
        :disabled="!taxonDetermination.otu_id"
        class="button normal-input button-submit separate-top"
        @click="addDetermination">
        Add
      </button>
      <draggable
        class="table-entrys-list"
        element="ul"
        v-model="list"
        @end="updatePosition">
        <template #item="{ element }">
          <li class="list-complete-item flex-separate middle">
            <span><span v-html="element.otuSelected"/> {{ authorsString() }} {{ dateString() }}</span>
            <div class="horizontal-left-content">
              <span
                class="circle-button btn-delete"
                :class="{ 'button-default': !element.id }"
                @click="removeTaxonDetermination(index)"/>
            </div>
          </li>
        </template>
      </draggable>
    </div>
  </div>
</template>

<script>

import { RouteNames } from 'routes/routes'

import SmartSelector from 'components/ui/SmartSelector.vue'
import RolePicker from 'components/role_picker.vue'
import CreatePerson from 'tasks/digitize/helpers/createPerson.js'
import Draggable from 'vuedraggable'

export default {
  components: {
    SmartSelector,
    RolePicker,
    Draggable
  },

  props: {
    modelValue: {
      type: Array,
      required: true
    }
  },

  emits: ['update:modelValue'],

  computed: {
    list: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  data () {
    return {
      taxonDetermination: this.newDetermination()
    }
  },

  methods: {
    roleExist (id) {
      return this.taxonDetermination.roles_attributes.find(role => !role?._destroy && role.person_id === id)
    },

    addRole (role) {
      if (!this.roleExist(role.id)) {
        this.taxonDetermination.roles_attributes.push(CreatePerson(role, 'Determiner'))
      }
    },

    addDetermination () {
      this.list.push(this.taxonDetermination)
      this.taxonDetermination = this.newDetermination()
    },

    setActualDate () {
      const today = new Date()
      this.taxonDetermination.day_made = today.getDate()
      this.taxonDetermination.month_made = today.getMonth() + 1
      this.taxonDetermination.year_made = today.getFullYear()
    },

    setOtu (otu) {
      this.taxonDetermination.otu_id = otu.id
      this.taxonDetermination.otuSelected = otu.object_tag
    },

    authorsString (role) {
      return role ? `by ${role?.person ? role.person.last_name : role.last_name}` : ''
    },

    dateString () {
      if (this.taxonDetermination.day_made || this.taxonDetermination.month_made || this.taxonDetermination.year_made) {
        return `on ${this.taxonDetermination.day_made ? `${this.taxonDetermination.day_made}-` : ''}${this.taxonDetermination.month_made ? `${this.taxonDetermination.month_made}-` : ''}${this.taxonDetermination.year_made ? `${this.taxonDetermination.year_made}` : ''}`
      }
      return ''
    },

    openBrowseOtu (id) {
      return `${RouteNames.BrowseOtu}?otu_id=${id}`
    },

    updatePosition () {
      for (let i = 0; i < this.list.length; i++) {
        this.list[i].position = (i + 1)
      }
    },

    removeTaxonDetermination (index) {
      this.list.splice(index, 1)
    },

    newDetermination () {
      return {
        biological_collection_object_id: undefined,
        otu_id: undefined,
        year_made: undefined,
        month_made: undefined,
        day_made: undefined,
        position: undefined,
        roles_attributes: []
      }
    }
  }
}
</script>
