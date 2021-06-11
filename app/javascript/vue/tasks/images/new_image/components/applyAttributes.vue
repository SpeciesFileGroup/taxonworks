<template>
  <div class="panel content">
    <h2>Use the options below to build attributions and depictions, then <i>Apply</i> them to your images.</h2>
    <div class="flexbox">
      <div class="separate-right">
        <div class="horizontal-left-content">
          <input
            class="input-apply"
            disabled="true"
            :value="showPeopleAndLicense"
            type="text">
          <button
            type="button"
            :disabled="!validateAttr || !imagesCreated"
            class="button normal-input button-submit separate-left"
            @click="applyAttr">
            Apply
          </button>
        </div>
        <div class="horizontal-left-content margin-small-top">
          <input
            class="input-apply"
            disabled="true"
            :value="objectsForDepictions"
            type="text">
          <button
            type="button"
            :disabled="!(validateDepic || validateSqedObject && imagesCreated)"
            class="button normal-input button-submit separate-left"
            @click="applyDepic">
            Apply
          </button>
        </div>
        <div class="horizontal-left-content margin-small-top">
          <input
            class="input-apply"
            disabled="true"
            :value="showPixelToCm"
            type="text">
          <button
            type="button"
            :disabled="!pixels || !imagesCreated"
            class="button normal-input button-submit separate-left"
            @click="applyPxToCm">
            Apply
          </button>
        </div>
      </div>
      <button
        class="button normal-input button-submit item button-apply-both "
        type="button"
        :disabled="!((validateDepic || validateSqedObject && validateAttr) && imagesCreated && this.pixels)"
        @click="applyAttr(); applyDepic(); applyPxToCm()">
        Apply all
      </button>
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters.js'
import { ActionNames } from '../store/actions/actions.js'
import validateSqed from '../helpers/validateSqed'

export default {
  computed: {
    source () {
      return this.$store.getters[GetterNames.GetSource]
    },
    validateSqedObject () {
      return validateSqed(this.getSqed)
    },
    getYear () {
      return this.$store.getters[GetterNames.GetYearCopyright]
    },
    getSqed () {
      return this.$store.getters[GetterNames.GetSqed]
    },
    imagesCreated () {
      return this.$store.getters[GetterNames.GetImagesCreated].length > 0
    },
    validateDepic () {
      return (this.$store.getters[GetterNames.GetObjectsForDepictions].length > 0)
    },
    validateAttr () {
      return (this.imagesBy.length > 0 || this.license.length)
    },
    authors () {
      return this.$store.getters[GetterNames.GetPeople].authors
    },
    editors () {
      return this.$store.getters[GetterNames.GetPeople].editors
    },
    owners () {
      return this.$store.getters[GetterNames.GetPeople].owners
    },
    copyrightHolder () {
      return this.$store.getters[GetterNames.GetPeople].copyrightHolder
    },
    license () {
      const tmp = this.$store.getters[GetterNames.GetLicense]
      return (tmp ? `License: ${tmp}` : '')
    },
    imagesBy () {
      const people = [].concat(this.getNames(this.authors),
        this.getNames(this.editors),
        this.getNames(this.owners),
        this.getNames(this.copyrightHolder))
      return people.length ? `Image(s) by ${people.join('; ')}.` : ''
    },
    pixels () {
      return this.$store.getters[GetterNames.GetPixels]
    },
    showPixelToCm () {
      return this.pixels ? `A scale of ${this.pixels} pixels per centimeter will be added` : 'The scale of pixels per centimeter will be displayed here when defined.'
    },
    showPeopleAndLicense () {
      if (this.imagesBy.length || this.license.length || this.source) {
        return `${this.imagesBy}${this.imagesBy.length > 0 ? ' ' : ''}${this.license ? `${this.license}. ` : ''}${this.source ? `Source: ${this.source.object_tag}` : ''}${this.getYear ? ` Copyright year ${this.getYear}` : ''}`
      }
      return 'The attribution summary will be displayed here when defined.'
    },
    objectsForDepictions () {
      if (!this.validateDepic) { return 'A depiction summary will be displayed here when defined. Otherwise a new collection object will be created for each image.' }

      const tmp = this.$store.getters[GetterNames.GetObjectsForDepictions].map(item => item.label)
      return tmp.length ? `Depicts some: ${tmp.join(', ')}` : 'A depiction summary will be displayed here when defined.'
    }
  },
  methods: {
    getNames (list) {
      return list.map(item => {
        if (item.hasOwnProperty('label')) {
          return item.label
        } else if (item.hasOwnProperty('person_attributes')) {
          return `${item.person_attributes.last_name}, ${item.person_attributes.first_name}`
        } else {
          return `${item.last_name}, ${item.first_name}`
        }
      })
    },
    applyAttr () {
      this.$store.dispatch(ActionNames.ApplyAttributions)
    },
    applyDepic () {
      this.$store.dispatch(ActionNames.ApplyDepictions)
    },
    applyPxToCm () {
      this.$store.dispatch(ActionNames.ApplyPixelToCentimeter)
    }
  }
}
</script>

<style scoped>
  .input-apply {
    width: 100%;
    font-size: 110%;
    color: #000000;
  }

  .button-apply-both {
    height: 97px;
  }
</style>
