<template>
  <div>
    <div class="flexbox separate-bottom">
      <person-box
        class="separate-right panel-section"
        v-model="authors"
        :options="['someone else']"
        role-type="AttributionCreator"
        title="Author/Creator"
      />
      <person-box
        class="separate-left separate-right panel-section"
        v-model="editors"
        :options="['someone else']"
        role-type="AttributionEditor"
        title="Editor"
      />
      <person-box
        class="separate-left panel-section"
        v-model="owners"
        role-type="AttributionOwner"
        title="Owner"
      />
    </div>
    <div class="flexbox">
      <licenses-section class="separate-right panel-section" />
      <source-component class="separate-left separate-right" />
      <copyright-holder
        class="separate-left"
        role-type="AttributionCopyrightHolder"
        title="Copyright holder"
      />
    </div>
  </div>
</template>

<script>

import PersonBox from './personsBox'
import CopyrightHolder from './copyrightHolder'
import LicensesSection from './licensesSection'
import { GetterNames } from '../store/getters/getters.js'
import { MutationNames } from '../store/mutations/mutations.js'
import SourceComponent from './source'

export default {
  components: {
    PersonBox,
    LicensesSection,
    CopyrightHolder,
    SourceComponent
  },

  computed: {
    owners: {
      get () {
        return this.$store.getters[GetterNames.GetPeople].owners
      },
      set (value) {
        this.$store.commit(MutationNames.SetOwners, value)
      }
    },

    authors: {
      get () {
        return this.$store.getters[GetterNames.GetPeople].authors
      },
      set (value) {
        this.$store.commit(MutationNames.SetAuthors, value)
      }
    },

    editors: {
      get () {
        return this.$store.getters[GetterNames.GetPeople].editors
      },
      set (value) {
        this.$store.commit(MutationNames.SetEditors, value)
      }
    }
  }
}
</script>
