<template>
  <form
    class="panel basic-information"
    >
    <a
      name="basic-information"
      class="anchor"/>
    <div class="header flex-separate middle">
      <h3
      v-help.section.basic.container
      >Basic information</h3>
      <expand
        @changed="expanded = !expanded"
        :expanded="expanded"/>
    </div>
    <div
      class="body horizontal-left-content align-start"
      v-show="expanded">
      <div class="column-left">
        <div class="field separate-right">
          <label v-help.section.basic.name>Name</label><br>
          <hard-validation field="name">
            <input
              slot="body"
              ref="inputTaxonname"
              class="taxonName-input"
              type="text"
              v-model="taxonName">
          </hard-validation>
        </div>
        <div class="field separate-top">
          <label v-help.section.basic.parent>Parent</label>
          <parent-picker/>
        </div>
        <rank-selector v-if="validateInfo"/>
        <hard-validation field="rank_class"/>

      </div>
      <div class="column-right item">
        <check-exist
          :max-results="0"
          :taxon="taxon"
          class="separate-left"
          url="/taxon_names/autocomplete"
          label="label_html"
          :search="taxon.name"
          param="term"
          :add-params="{ exact: true, 'type[]': 'Protonym' }"/>
      </div>
    </div>
    <div
      class="body"
      v-if="!taxon.id">
      <save-taxon-name class="normal-input button button-submit create-button"/>
    </div>
    <modal-component 
      v-if="showModal"
      @close="showModal = false">
      <h3 slot="header">Non latinized name</h3>
      <div slot="body">
        <p>Create this name and apply the non-latin status?</p>
        <button
          class="button normal-input button-submit"
          type="button"
          @click="createNonLatin">
          Create
        </button>
      </div>
    </modal-component>
  </form>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'

import SaveTaxonName from './saveTaxonName.vue'
import ParentPicker from './parentPicker.vue'
import Expand from './expand.vue'
import CheckExist from './findExistTaxonName.vue'
import RankSelector from './rankSelector.vue'
import HardValidation from './hardValidation.vue'
import ModalComponent from 'components/modal'

export default {
  components: {
    ParentPicker,
    Expand,
    RankSelector,
    CheckExist,
    SaveTaxonName,
    HardValidation,
    ModalComponent
  },
  computed: {
    parent () {
      return this.$store.getters[GetterNames.GetParent]
    },
    taxon: {
      get () {
        return this.$store.getters[GetterNames.GetTaxon]
      },
      set (value) {
        this.$store.commit(MutationNames.SetTaxon)
      }
    },
    validateInfo () {
      return (this.parent != undefined && 
        (this.taxon.name != undefined && 
        this.taxon.name.replace(/\s/g, '').length > 2))
    },
    taxonName: {
      get () {
        return this.$store.getters[GetterNames.GetTaxonName]
      },
      set (value) {
        this.$store.commit(MutationNames.SetTaxonName, value)
        this.$store.commit(MutationNames.UpdateLastChange)
      }
    },
    errors () {
      return this.$store.getters[GetterNames.GetHardValidation]
    }
  },
  data: function () {
    return {
      expanded: true,
      showModal: false
    }
  },
  watch: {
    errors: {
      handler(newVal) {
        console.log(newVal)
        if(this.existError('name')) {
          if(this.displayError('name').find(item => { return item.includes('must be latinized') })) {
            this.showModal = true
          }
        }
      },
      deep: true
    }
  },
  mounted() {
    this.$refs.inputTaxonname.focus()
  },
  methods: {
    existError: function (type) {
      return (this.errors && this.errors.hasOwnProperty(type))
    },
    displayError (type) {
      if (this.existError(type)) {
        return this.errors[type]
      } else {
        return undefined
      }
    },
    createNonLatin() {
      let code = this.$store.getters[GetterNames.GetNomenclaturalCode]
      let statusList = this.$store.getters[GetterNames.GetStatusList][code]
      let statusType = Object.values(statusList.all).find(item => { return item.name.includes('not latin')})
      this.taxon.taxon_name_classifications_attributes = [{
        type: statusType.type
      }]

      this.$store.dispatch(ActionNames.CreateTaxonName, this.taxon)
      this.showModal = false
    }
  }
}
</script>

<style lang="scss">
  .basic-information {
    transition: all 1s;
    .validation-warning {
      border-left: 4px solid #ff8c00 !important;
    }
    .create-button {
      min-width: 100px;
    }

    height: 100%;
    box-sizing: border-box;
    display: flex;
    flex-direction: column;
    .header {
      border-left:4px solid green;
      h3 {
      font-weight: 300;
    }
    padding: 1em;
    padding-left: 1.5em;
    border-bottom: 1px solid #f5f5f5;
    }
    .body {
      padding: 2em;
      padding-top: 1em;
      padding-bottom: 1em;
    }
    .vue-autocomplete-input {
      width: 300px;
    }
    .taxonName-input,#error_explanation {
      width: 300px;
    }
  }
</style>
