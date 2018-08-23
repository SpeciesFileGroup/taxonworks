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
              class="taxonName-input"
              type="text"
              v-model="taxonName">
          </hard-validation>
        </div>
        <div class="field separate-top">
          <label v-help.section.basic.parent>Parent</label>
          <parent-picker/>
        </div>
        <rank-selector v-if="parent"/>
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
  </form>
</template>

<script>

const GetterNames = require('../store/getters/getters').GetterNames
const MutationNames = require('../store/mutations/mutations').MutationNames

var saveTaxonName = require('./saveTaxonName.vue').default
var parentPicker = require('./parentPicker.vue').default
var taxonName = require('./taxonName.vue').default
var expand = require('./expand.vue').default
var checkExist = require('./findExistTaxonName.vue').default
var rankSelector = require('./rankSelector.vue').default
var hardValidation = require('./hardValidation.vue').default

export default {
  components: {
    parentPicker,
    taxonName,
    expand,
    rankSelector,
    checkExist,
    saveTaxonName,
    hardValidation
  },
  computed: {
    parent () {
      return this.$store.getters[GetterNames.GetParent]
    },
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
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
      expanded: true
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
