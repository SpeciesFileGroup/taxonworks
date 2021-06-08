<template>
  <nav-bar class="position-relative">
    <div class="flex-separate">
      <ul class="no_bullets context-menu">
        <template
          v-for="(link, key, index) in menu"
          :key="key">
          <li
            class="navigation-item context-menu-option"
            v-if="link">
            <a
              data-turbolinks="false"
              :class="{ active : (activePosition == index)}"
              :href="'#' + key.toLowerCase().replace(' ','-')"
              @click="activePosition = index">{{ key }}
            </a>
          </li>
        </template>
      </ul>
      <div class="horizontal-center-content">
        <save-taxon-name
          v-if="taxon.id"
          class="normal-input button button-submit separate-right"/>
        <clone-taxon-name
          v-help.section.navbar.clone
          class="separate-right"/>
        <button
          type="button"
          title="Create a child of this taxon name"
          v-help.section.navbar.sisterIcon
          @click="createNew(taxon.id)"
          :disabled="!taxon.id"
          class="button normal-input button-default btn-create-child button-new-icon margin-small-right"/>
        <button
          type="button"
          @click="createNew(parentId)"
          :disabled="!parentId"
          title="Create a new taxon name with the same parent"
          v-help.section.navbar.childIcon
          class="button normal-input button-default btn-create-sister button-new-icon margin-small-right"/>
        <create-new-button />
      </div>
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
import NavBar from 'components/layout/NavBar'
import Autosave from './autosave'
import { GetterNames } from '../store/getters/getters'
import { RouteNames } from 'routes/routes'

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
    parent () {
      return this.$store.getters[GetterNames.GetParent]
    },
    isAutosaveActive () {
      return this.$store.getters[GetterNames.GetAutosave]
    },
    parentId () {
      return this.parent?.id
    }
  },
  data () {
    return {
      activePosition: 0
    }
  },
  methods: {
    createNew (id) {
      this.url = `${RouteNames.NewTaxonName}?parent_id=${id}`
      if (this.unsavedChanges) {
        if (window.confirm('You have unsaved changes. Are you sure you want to create a new taxon name? All unsaved changes will be lost.')) {
          window.open(this.url, '_self')
        }
      } else {
        window.open(this.url, '_self')
      }
    }
  }
}
</script>
<style lang="scss" scoped>

  ::v-deep button {
    min-width: 80px;
    width: 100%;
  }

  .button-new-icon {
    min-width: 28px;
    max-width: 28px;
    background-position: center;
    background-repeat: no-repeat;
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
