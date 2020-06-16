<template>
  <nav-bar class="position-relative">
    <div class="flex-separate">
      <ul class="no_bullets context-menu">
        <li
          class="navigation-item context-menu-option"
          v-for="(link, key, index) in menu"
          v-if="link">
          <a
            data-turbolinks="false"
            :class="{ active : (activePosition == index)}"
            :href="'#' + key.toLowerCase().replace(' ','-')"
            @click="activePosition = index">{{ key }}
          </a>
        </li>
      </ul>
      <form class="horizontal-center-content">
        <label class="horizontal-left-content middle margin-medium-right">
          <input
            type="checkbox"
            v-model="isAutosaveActive">
          Autosave
        </label>
        <transition name="fade">
          <span
            data-icon="warning"
            title="You have unsaved changes."
            class="medium-icon separate-right"
            v-if="unsavedChanges"/>
        </transition>
        <save-taxon-name
          v-if="taxon.id"
          class="normal-input button button-submit separate-right"/>
        <clone-taxon-name class="separate-right"/>
        <create-new-button />
      </form>
    </div>
    <autosave
      style="bottom: 0px; left: 0px;"
      class="position-absolute full_width"
      :disabled="!taxon.id || !isAutosaveActive"/>
  </nav-bar>
</template>
<script>

import SaveTaxonName from './saveTaxonName.vue'
import CreateNewButton from './createNewButton.vue'
import CloneTaxonName from './cloneTaxon'
import NavBar from 'components/navBar'
import Autosave from './autosave'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { convertType } from 'helpers/types.js'

export default {
  components: {
    SaveTaxonName,
    CreateNewButton,
    CloneTaxonName,
    NavBar,
    Autosave
  },
  props: {
    menu: {
      type: Object,
      required: true
    }
  },
  computed: {
    unsavedChanges () {
      return (this.$store.getters[GetterNames.GetLastChange] > this.$store.getters[GetterNames.GetLastSave])
    },
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    isAutosaveActive: {
      get () {
        return this.$store.getters[GetterNames.GetAutosave]
      },
      set (value) {
        this.$store.commit(MutationNames.SetAutosave, value)
      }
    }
  },
  data () {
    return {
      activePosition: 0
    }
  },
  watch: {
    isAutosaveActive (newVal) {
      sessionStorage.setItem('task::newtaxonname::autosave', newVal)
    }
  },
  mounted () {
    const value = convertType(sessionStorage.getItem('task::newtaxonname::autosave'))
    this.isAutosaveActive = value === null ? false : value
  }
}
</script>
<style lang="scss" scoped>

  /deep/ button {
    min-width: 100px;
    width: 100%;
  }
  .taxonname {
    font-weight: 300;
  }
  .unsaved
  li {
    a {
      font-size: 13px;
    }
    a:first-child {
      padding-left: 0px;
    }
  }

</style>
