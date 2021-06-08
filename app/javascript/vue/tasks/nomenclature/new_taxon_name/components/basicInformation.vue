<template>
  <block-layout
    class="basic-information"
    anchor="basic-information">
    <h3 slot="header">Basic information</h3>
    <template #body>
      <div class="horizontal-left-content align-start">
        <div class="column-left">
          <div class="field separate-right label-above">
            <label
              v-help.section.basic.name
              for="taxon-name">Name</label>
            <hard-validation field="name">
              <template #body>
                <input
                  id="taxon-name"
                  ref="inputTaxonname"
                  class="taxonName-input"
                  type="text"
                  autocomplete="off"
                  name="name"
                  v-model="taxonName">
              </template>
            </hard-validation>
          </div>
          <div class="field separate-top">
            <label
              v-help.section.basic.parent
              for="parent-name">Parent</label>
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
        v-if="!taxon.id"
        class="margin-large-top">
        <save-taxon-name class="normal-input button button-submit create-button"/>
      </div>
    </template>
    <modal-component
      v-if="showModal"
      @close="showModal = false">
      <template #header>
        <h3>Non latinized name</h3>
      </template>
      <template #body>
        <p>{{ taxon.id ? 'Update' : 'Create' }} this name and apply the non-latin status?</p>
        <button
          class="button normal-input button-submit"
          type="button"
          @click="createNonLatin">
          {{ taxon.id ? 'Update' : 'Create' }}
        </button>
      </template>
    </modal-component>
  </block-layout>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'

import SaveTaxonName from './saveTaxonName.vue'
import ParentPicker from './parentPicker.vue'
import CheckExist from './findExistTaxonName.vue'
import RankSelector from './rankSelector.vue'
import HardValidation from './hardValidation.vue'
import ModalComponent from 'components/ui/Modal'
import BlockLayout from 'components/layout/BlockLayout'

export default {
  components: {
    ParentPicker,
    RankSelector,
    CheckExist,
    SaveTaxonName,
    HardValidation,
    ModalComponent,
    BlockLayout
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
      return true
    },
    taxonName: {
      get () {
        return this.$store.getters[GetterNames.GetTaxonName]
      },
      set (value) {
        this.$store.commit(MutationNames.SetTaxonName, value)
        if (!this.taxon.id) {
          this.$store.commit(MutationNames.UpdateLastChange)
        }
      }
    },
    errors () {
      return this.$store.getters[GetterNames.GetHardValidation]
    }
  },
  data: function () {
    return {
      showModal: false
    }
  },
  watch: {
    errors: {
      handler(newVal) {
        if(this.existError('name')) {
          if(this.displayError('name').find(item => { return item.includes('must be latinized') })) {
            this.showModal = true
          }
        }
      },
      deep: true
    }
  },
  mounted () {
    const urlParams = new URLSearchParams(window.location.search)
    const name = urlParams.get('name')

    this.$refs.inputTaxonname.focus()

    if (name) {
      this.taxonName = ''
      this.$nextTick(() => {
        this.taxonName = name
      })
    }
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
      if (this.taxon.id) {
        this.$store.dispatch(ActionNames.AddTaxonStatus, {
          type: statusType.type,
          name: statusType.name
        }).then(() => {
          this.$store.dispatch(ActionNames.UpdateTaxonName, this.taxon).then(() => {
            this.$store.dispatch(ActionNames.LoadTaxonStatus, this.taxon.id)
          })
        })
      } else {
        this.taxon.taxon_name_classifications_attributes = [{ type: statusType.type }]
        this.$store.dispatch(ActionNames.CreateTaxonName, this.taxon).then(() => {
          this.$store.dispatch(ActionNames.LoadTaxonStatus, this.taxon.id)
        })
      }
      this.showModal = false
    }
  }
}
</script>

<style lang="scss">
  .basic-information {
    .vue-autocomplete-input {
      width: 300px;
    }
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
    .taxonName-input,#error_explanation {
      width: 300px;
    }
  }
</style>
