<template>
  <block-layout
    anchor="original-combination"
    v-if="isInvalid && validTaxon && childrenList.length"
    v-help.section.originalCombination.container>
    <h3 slot="header">Manage synonymy</h3>
    <div
      slot="body">
      <spinner-component
        :full-screen="true"
        legend="Saving changes..."
        :logo-size="{ width: '100px', height: '100px'}"
        v-if="saving"/>
      <spinner-component
        legend="Loading..."
        :logo-size="{ width: '100px', height: '100px'}"
        v-if="isLoading"/>
      <div>
        <p>This name is invalid. The valid name is <span v-html="validTaxon.name"/></p>
        <div class="horizontal-right-content">
          <button
            class="button normal-input button-default separate-right"
            @click="selectAll">
            All
          </button>
          <button
            class="button normal-input button-default"
            @click="selected = []">
            None
          </button>
        </div>
        <table class="full_width margin-small-bottom margin-small-top">
          <thead>
            <tr>
              <th>Child</th>
              <th>Valid</th>
              <th>Current parent</th>
              <th>New parent</th>
              <th>Options</th>
              <th>Select</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="children in childrenList">
              <td>
                {{ children.name }}
              </td>
              <td>
                {{ children.id == children.cached_valid_taxon_name_id ? 'Yes' : 'No' }}
              </td>
              <td v-html="children.parent.name"/>
              <td>
                <autocomplete
                  url="/taxon_names/autocomplete"
                  param="term"
                  min="2"
                  label="label"
                  @getItem="addPreSelected(children.id, $event.id)"
                  :add-params="{ type: 'Protonym', 'nomenclature_group[]': 'Genus' }"
                  :placeholder="validTaxon.name"/>
              </td>
              <td class="horizontal-left-content">
                <span
                  class="circle-button btn-edit"
                  @click="loadTaxon(children.id)"/>
                <radial-annotator :global-id="children.global_id"/>
              </td>
              <td>
                <input
                  :value="children.id"
                  type="checkbox"
                  v-model="selected"/>
              </td>
            </tr>
          </tbody>
        </table>
        <button
          class="button normal-input button-submit"
          :disabled="!selected.length"
          @click="confirmSave">
          Save
        </button>
      </div>
    </div>
    <modal-component
      v-if="showModal"
      @close="showModal = false">
      <h3 slot="header">Move taxon names</h3>
      <div slot="body">
        <p>
          This will change all taxon parents. Are you sure you want to proceed? Type "MOVE" to proceed.
        </p>
        <input
          type="text"
          class="full_width"
          v-model="moveInput"
          placeholder="Wirte MOVE to continue">
      </div>
      <div slot="footer">
        <button 
          type="button"
          class="button normal-input button-submit"
          :disabled="checkInput"
          @click="saveTaxonNames()">
          Move all
        </button>
      </div>
    </modal-component>
  </block-layout>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import RadialAnnotator from 'components/radials/annotator/annotator'
import BlockLayout from './blockLayout'
import ModalComponent from 'components/modal'
import SpinnerComponent from 'components/spinner'
import Autocomplete from 'components/autocomplete'

export default {
  components: {
    ModalComponent,
    RadialAnnotator,
    SpinnerComponent,
    Autocomplete,
    BlockLayout
  },
  computed: {
    taxon() {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    isInvalid() {
      return this.taxon.id != this.taxon.cached_valid_taxon_name_id
    },
    checkInput() {
      return this.moveInput.toUpperCase() != 'MOVE'
    }
  },
  data() {
    return {
      childrenList: [],
      selected: [],
      expanded: true,
      validTaxon: undefined,
      showModal: false,
      moveInput: '',
      saving: false,
      preSelected: [],
      isLoading: false
    }
  },
  watch: {
    taxon: {
      handler(newVal) {
        if(newVal && newVal.id != newVal.cached_valid_taxon_name_id) {
          this.$http.get(`/taxon_names/${this.taxon.cached_valid_taxon_name_id}.json`).then(res => {
            this.validTaxon = res.body
            this.isLoading = true
            this.$http.get(`/taxon_names.json?taxon_name_id[]=${this.taxon.id}&descendants=true`).then(response => {
              this.childrenList = response.body.filter(item => { return item.id != this.taxon.id })
              this.isLoading = false
            })
          })
        }
      },
      immediate: true
    }
  },
  methods: {
    selectAll() {
      this.selected = this.childrenList.map((children) => { return children.id })
    },
    loadTaxon(id) {
      if(window.confirm(`Are you sure you want to load this taxon name?`)) {
        window.open(`/tasks/nomenclature/new_taxon_name/${id}`,`_self`)
      }
    },
    confirmSave() {
      if(this.selected.length >= 10) {
        this.showModal = true
      }
      else {
        if(window.confirm(`Are you sure you want to proceed?`)) {
          this.saveTaxonNames()
        }
      }
    },
    saveTaxonNames() {
      let promises = []
      
      this.saving = true
      this.showModal = false
      this.moveInput = ''

      this.selected.forEach((id, index) => {
        let findPreSelected = this.preSelected.find(children => {
          return children.childrenId == id
        })
        if(findPreSelected) {
          promises.push(this.$http.patch(`/taxon_names/${id}`, { taxon_name: { parent_id: findPreSelected.parentId } }))
        }
        else {
          promises.push(this.$http.patch(`/taxon_names/${id}`, { taxon_name: { parent_id: this.taxon.cached_valid_taxon_name_id } }))
        }
      })

      Promise.all(promises).then(() => {
        this.childrenList = this.childrenList.filter(children => {
          return !this.selected.includes(children.id)
        })
        this.selected = [],
        this.preSelected = []
        this.saving = false
        TW.workbench.alert.create(`Taxon name was successfully moved.`, 'notice')
      }, (response) => {
        TW.workbench.alert.create(`Something went wrong: ${JSON.stringify(response.body)}`, 'error')
        this.saving = false
      })
    },
    addPreSelected(childrenId, parentId) {
      this.preSelected.push({ 
        childrenId: childrenId, 
        parentId: parentId
      })
    }
  }
}
</script>
