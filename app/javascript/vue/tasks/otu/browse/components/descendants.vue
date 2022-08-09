<template>
  <section-panel
    :spinner="isLoading"
    :status="status"
    :title="title"
    menu
    @menu="showModal = true">
    <tree-view
      :current-taxon-id="otu.taxon_name_id"
      :only-valid="onlyValid"
      :list="childOfCurrentName"/>
    <modal-component
      v-if="showModal"
      @close="showModal = false">
      <template #header>
        <h3>Filter</h3>
      </template>
      <template #body>
        <ul class="no_bullets">
          <li>
            <label>
              <input
                v-model="onlyChildrens"
                type="checkbox">
              Show children only
            </label>
          </li>
          <li>
            <label>
              <input
                v-model="onlyValid"
                type="checkbox">
              Show only valid names
            </label>
          </li>
        </ul>
      </template>
    </modal-component>
  </section-panel>
</template>

<script>

import SectionPanel from './shared/sectionPanel'
import ModalComponent from 'components/ui/Modal'
import TreeView from './TreeView'
import extendSection from './shared/extendSections'
import { GetterNames } from '../store/getters/getters'

export default {
  mixins: [extendSection],
  components: {
    SectionPanel,
    ModalComponent,
    TreeView
  },
  props: {
    otu: {
      type: Object,
      required: true
    }
  },
  computed: {
    childOfCurrentName () {
      return (this.onlyChildrens ? this.children.filter(child => this.otu.taxon_name_id === child.parent_id) : this.children).sort((a, b) => {
        if (a.cached > b.cached) {
          return 1
        }
        if (b.cached > a.cached) {
          return -1
        }
        return 0
      })
    },
    children () {
      return this.$store.getters[GetterNames.GetDescendants].taxon_names
    },
    isLoading () {
      return this.$store.getters[GetterNames.GetLoadState].descendants
    }
  },
  data () {
    return {
      onlyChildrens: true,
      onlyValid: true,
      max: 10,
      showAll: false,
      showModal: false
    }
  },
  methods: {
    showChildrensOf (taxon) {
      return this.children.filter(item => { return taxon.id === item.parent_id })
    }
  }
}
</script>