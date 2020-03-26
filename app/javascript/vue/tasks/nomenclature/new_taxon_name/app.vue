<template>
  <div id="new_taxon_name_task">
    <div class="flex-separate middle">
      <h1>{{ (getTaxon.id ? 'Edit' : 'New') }} taxon name</h1>
      <autocomplete
        class="autocomplete-search-bar"
        url="/taxon_names/autocomplete"
        param="term"
        :add-params="{ 'type[]': 'Protonym' }"
        label="label_html"
        placeholder="Search a taxon name..."
        @getItem="loadTaxon"
        :clearAfter="true"/>
    </div>
    <div>
      <nav-header :menu="menu"/>
      <div class="flexbox horizontal-center-content align-start">
        <div class="ccenter item separate-right">
          <spinner
            :full-screen="true"
            :legend="(loading ? 'Loading...' : 'Saving changes...')"
            :logo-size="{ width: '100px', height: '100px'}"
            v-if="loading || getSaving"/>
          <basic-information class="separate-bottom"/>
          <div class="new-taxon-name-block">
            <spinner
              :show-spinner="false"
              :show-legend="false"
              v-if="!getTaxon.id"/>
            <source-picker class="separate-top separate-bottom"/>
          </div>
          <div class="new-taxon-name-block">
            <spinner
              :show-spinner="false"
              :show-legend="false"
              v-if="!getTaxon.id"/>
            <status-picker class="separate-top separate-bottom"/>
          </div>
          <div class="new-taxon-name-block">
            <spinner
              :show-spinner="false"
              :show-legend="false"
              v-if="!getTaxon.id"/>
            <relationship-picker class="separate-top separate-bottom"/>
          </div>
          <div
            class="new-taxon-name-block"
            v-if="showForThisGroup(['GenusGroup', 'FamilyGroup'], getTaxon)">
            <spinner
              :show-spinner="false"
              :show-legend="false"
              v-if="!getTaxon.id"/>
            <manage-synonymy class="separate-bottom"/>
          </div>          
          <div class="new-taxon-name-block">
            <type-block
              v-if="getTaxon.id && showForThisGroup(['FamilyGroup','GenusGroup', 'SpeciesGroup', 'SpeciesAndInfraspeciesGroup'], getTaxon)"
              class="separate-top separate-bottom"/>
          </div>
          <div
            class="new-taxon-name-block"
            v-if="showForThisGroup(['SpeciesGroup','GenusGroup', 'SpeciesAndInfraspeciesGroup'], getTaxon)">
            <spinner
              :show-spinner="false"
              :show-legend="false"
              v-if="!getTaxon.id"/>
            <block-layout
              anchor="original-combination"
              v-help.section.originalCombination.container>
              <h3 slot="header">Original combination and classification</h3>
              <div slot="body">
                <pick-original-combination/>
              </div>
            </block-layout>
          </div>
          <div
            class="new-taxon-name-block"
            v-if="showForThisGroup(['SpeciesGroup','GenusGroup', 'SpeciesAndInfraspeciesGroup'], getTaxon)">
            <spinner
              :show-spinner="false"
              :show-legend="false"
              v-if="!getTaxon.id"/>
            <gender-block class="separate-top separate-bottom"/>
          </div>
          <div
            class="new-taxon-name-block"
            v-if="getTaxon.id && showForThisGroup(['SpeciesGroup','GenusGroup', 'SpeciesAndInfraspeciesGroup'], getTaxon)">
            <spinner
              :show-spinner="false"
              :show-legend="false"
              v-if="!getTaxon.id"/>
            <etymology class="separate-top separate-bottom"/>
          </div>
        </div>
        <div
          v-if="getTaxon.id"
          class="cright item separate-left">
          <div id="cright-panel">
            <check-changes/>
            <taxon-name-box class="separate-bottom"/>
            <soft-validation class="separate-top"/>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import Autocomplete from 'components/autocomplete'
import showForThisGroup from './helpers/showForThisGroup'
import SourcePicker from './components/sourcePicker.vue'
import RelationshipPicker from './components/relationshipPicker.vue'
import StatusPicker from './components/statusPicker.vue'
import NavHeader from './components/navHeader.vue'
import TaxonNameBox from './components/taxonNameBox.vue'
import Etymology from './components/etymology.vue'
import GenderBlock from './components/gender.vue'
import CheckChanges from './components/checkChanges.vue'
import TypeBlock from './components/type.vue'
import BasicInformation from './components/basicInformation.vue'
import PickOriginalCombination from './components/pickOriginalCombination.vue'
import ManageSynonymy from './components/manageSynonym'

import SoftValidation from './components/softValidation.vue'
import Spinner from 'components/spinner.vue'
import BlockLayout from './components/blockLayout'

import { GetterNames } from './store/getters/getters'
import { MutationNames } from './store/mutations/mutations'
import { ActionNames } from './store/actions/actions'

export default {
  components: {
    Autocomplete,
    Etymology,
    SourcePicker,
    Spinner,
    NavHeader,
    StatusPicker,
    TaxonNameBox,
    RelationshipPicker,
    BasicInformation,
    SoftValidation,
    BlockLayout,
    ManageSynonymy,
    PickOriginalCombination,
    TypeBlock,
    GenderBlock,
    CheckChanges
  },
  computed: {
    getTaxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    getSaving () {
      return this.$store.getters[GetterNames.GetSaving]
    },
    menu () {
      return {
        'Basic information': true,
        'Author': true,
        'Status': true,
        'Relationship': true,
        'Type': showForThisGroup(['SpeciesGroup', 'GenusGroup', 'FamilyGroup', 'SpeciesAndInfraspeciesGroup'], this.getTaxon),
        'Original combination': showForThisGroup(['SpeciesGroup', 'GenusGroup', 'SpeciesAndInfraspeciesGroup'], this.getTaxon),
        'Etymology': showForThisGroup(['SpeciesGroup', 'GenusGroup', 'SpeciesAndInfraspeciesGroup'], this.getTaxon),
        'Gender': showForThisGroup(['SpeciesGroup', 'GenusGroup', 'SpeciesAndInfraspeciesGroup'], this.getTaxon)
      }
    }
  },
  data () {
    return {
      loading: true
    }
  },
  mounted () {
    let that = this
    let urlParams = new URLSearchParams(window.location.search)
    let taxonId = urlParams.get('taxon_name_id')

    if(!taxonId) {
      taxonId = location.pathname.split('/')[4]
    }

    window.addEventListener('scroll', this.scrollBox)
    
    this.initLoad().then(function () {
      if (/^\d+$/.test(taxonId)) {
        that.$store.dispatch(ActionNames.LoadTaxonName, taxonId).then(function () {
          that.$store.dispatch(ActionNames.LoadTaxonStatus, taxonId)
          that.$store.dispatch(ActionNames.LoadTaxonRelationships, taxonId)
          that.loading = false
        }, () => {
          that.loading = false
        })
      } else {
        that.loading = false
      }
    })

    this.addShortcutsDescription()
  },
  methods: {
    scrollBox () {
      let element = document.querySelector('#new_taxon_name_task #cright-panel')

      if (element) {
        if (((window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop || 0) > 154) && (this.isMinor())) {
          element.classList.add('cright-fixed-top')
        } else {
          element.classList.remove('cright-fixed-top')
        }
      }
    },
    addShortcutsDescription () {
      TW.workbench.keyboard.createLegend(`${this.getMacKey()}+s`, 'Save taxon name changes', 'New taxon name')
      TW.workbench.keyboard.createLegend(`${this.getMacKey()}+n`, 'Create a new taxon name', 'New taxon name')
      TW.workbench.keyboard.createLegend(`${this.getMacKey()}+p`, 'Create a new taxon name with the same parent', 'New taxon name')
      TW.workbench.keyboard.createLegend(`${this.getMacKey()}+d`, 'Create a child of this taxon name', 'New taxon name')
      TW.workbench.keyboard.createLegend(`${this.getMacKey()}+l`, 'Clone this taxon name', 'New taxon name')
    },
    getMacKey: function () {
      return (navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt')
    },
    isMinor: function () {
      let element = document.querySelector('#cright-panel')
      let navBar = document.querySelector('#taxonNavBar')

      if (element && navBar) {
        return ((element.offsetHeight + navBar.offsetHeight) < window.innerHeight)
      } else {
        return true
      }
    },
    showForThisGroup: showForThisGroup,
    initLoad: function () {
      let that = this
      let actions = [
        this.$store.dispatch(ActionNames.LoadRanks),
        this.$store.dispatch(ActionNames.LoadStatus),
        this.$store.dispatch(ActionNames.LoadRelationships)
      ]
      return new Promise(function (resolve, reject) {
        Promise.all(actions).then(function () {
          that.$store.commit(MutationNames.SetInitLoad, true)
          return resolve(true)
        })
      })
    },
    loadTaxon (taxon) {
      window.open(`/tasks/nomenclature/new_taxon_name?taxon_name_id=${taxon.id}`, '_self')
    }
  }
}

</script>
<style lang="scss">
  #new_taxon_name_task {
    flex-direction: column-reverse;
    margin: 0 auto;
    margin-top: 1em;
    max-width: 1240px;

    .autocomplete-search-bar {
      input {
        width: 500px;
      }
    }

    .cleft, .cright {
      min-width: 350px;
      max-width: 350px;
      width: 300px;
    }
    .ccenter {
      max-width: 1240px;
    }
    #cright-panel {
      width: 350px;
      max-width: 350px;
    }
    .cright-fixed-top {
      top:68px;
      width: 1240px;
      z-index:200;
      position: fixed;
    }
    .anchor {
       display:block;
       height:65px;
       margin-top:-65px;
       visibility:hidden;
    }
    hr {
        height: 1px;
        color: #f5f5f5;
        background: #f5f5f5;
        font-size: 0;
        margin: 15px;
        border: 0;
    }
  }

</style>
