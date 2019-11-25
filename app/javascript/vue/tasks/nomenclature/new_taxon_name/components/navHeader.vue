<template>
  <nav-bar>
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
  </nav-bar>
</template>
<script>

import SaveTaxonName from './saveTaxonName.vue'
import CreateNewButton from './createNewButton.vue'
import CloneTaxonName from './cloneTaxon'
import NavBar from 'components/navBar'
import { GetterNames } from '../store/getters/getters'

export default {
  props: {
    menu: {
      type: Object,
      required: true
    }
  },
  components: {
    SaveTaxonName,
    CreateNewButton,
    CloneTaxonName,
    NavBar
  },
  computed: {
    unsavedChanges () {
      return (this.$store.getters[GetterNames.GetLastChange] > this.$store.getters[GetterNames.GetLastSave])
    },
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    }
  },
  data () {
    return {
      activePosition: 0
    }
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
