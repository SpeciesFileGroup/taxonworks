<template>
  <div class="panel content">
    <h2>Use the options below to build attributions and depictions, then apply it to your images.</h2>
    <div class="flexbox">
      <div class="separate-right">
        <div class="horizontal-left-content separate-bottom">
          <input
            class="input-apply"
            disabled="true"
            :value="showPeopleAndLicense"
            type="text">
          <button
            type="button"
            class="button normal-input button-submit separate-left">
            Apply
          </button>
        </div>
        <div class="horizontal-left-content">
          <input
            class="input-apply"
            disabled="true"
            type="text">
          <button
            type="button"
            class="button normal-input button-submit separate-left">
            Apply
          </button>
        </div>
      </div>
      <button 
        class="button normal-input button-submit item button-apply-both "
        type="button">
        Apply both
      </button>
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters.js'

export default {
  computed: {
    authors() {
      return this.$store.getters[GetterNames.GetPeople].authors
    },
    editors() {
      return this.$store.getters[GetterNames.GetPeople].editors
    },
    owners() {
      return this.$store.getters[GetterNames.GetPeople].owners
    },
    copyrightHolder() {
      return this.$store.getters[GetterNames.GetPeople].copyrightHolder
    },
    license() {
      let tmp = this.$store.getters[GetterNames.GetLicense]
      return (tmp ? `License: ${tmp}` : '')
    },
    imagesBy() {
      let people = [].concat(this.getNames(this.authors), 
        this.getNames(this.editors), 
        this.getNames(this.owners), 
        this.getNames(this.copyrightHolder))
      return people.length ? `Image(s) by ${people.join('; ')}.` : ''
    },
    showPeopleAndLicense() {
      return `${this.imagesBy}${this.imagesBy.length > 0 ? ` ${this.license}` : this.license}`
    }
  },
  methods: {
    getNames(list) {
      
      let ppl = list.map(item => {
        if(item.hasOwnProperty('person_attributes'))
          return `${item.person_attributes.last_name}, ${item.person_attributes.first_name}`
        else 
          return `${item.last_name}, ${item.first_name}`
      })


      return ppl
    }
  }
}
</script>

<style scoped>
  .input-apply {
    width: 100%;
  }

  .button-apply-both {
    height: 69px;
  }
</style>
