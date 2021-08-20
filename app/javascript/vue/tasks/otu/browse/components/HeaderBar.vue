<template>
  <div class="panel separate-bottom">
    <div
      class="content"
      :class="{ 'feedback-warning': isInvalid }"
      v-hotkey="shortcuts"
    >
      <ul
        v-if="navigation"
        class="breadcrumb_list">
        <li
          v-for="(item, key) in navigation.parents"
          :key="key"
          class="breadcrumb_item">
          <a
            v-if="item.length === 1"
            :href="`/tasks/otus/browse/${item[0].id}`">
            {{ key }}
          </a>
          <div
            v-else
            class="dropdown-otu">
            <a>{{ key }}</a>
            <ul class="panel dropdown no_bullets">
              <li>Parents</li>
              <li
                v-for="otu in item"
                :key="otu.id">
                <a :href="`/tasks/otus/browse/${otu.id}`">{{ otu.object_label }}</a>
              </li>
            </ul>
          </div>
        </li>
        <li
          class="breadcrumb_item current_breadcrumb_position"
          v-html="navigation.current_otu.object_label"/>
      </ul>
      <div class="horizontal-left-content middle">
        <h2 v-html="otu.object_tag"/>
        <div
          class="horizontal-left-content">
          <browse-taxon
            v-if="otu.taxon_name_id"
            ref="browseTaxon"
            :object-id="otu.taxon_name_id"/>
          <radial-annotator
            :global-id="otu.global_id"
            type="annotations"/>
          <radial-object
            :global-id="otu.global_id"
            type="annotations"/>
          <quick-forms :global-id="otu.global_id"/>
          <button
            v-if="isInvalid"
            v-help.section.header.validButton
            class="button button-default normal-input"
            @click="openValid">
            Browse current OTU
          </button>
        </div>
      </div>
      <ul
        class="context-menu no_bullets">
        <template
          v-for="item in menu"
          :key="item">
          <li v-show="showForRanks(item)">
            <a
              data-turbolinks="false"
              :href="`#${item}`"
            >{{item}}</a>
          </li>
        </template>
      </ul>
    </div>
  </div>
</template>

<script>

import RadialAnnotator from 'components/radials/annotator/annotator'
import RadialObject from 'components/radials/navigation/radial.vue'
import QuickForms from 'components/radials/object/radial.vue'
import BrowseTaxon from 'components/taxon_names/browseTaxon.vue'
import platformKey from 'helpers/getPlatformKey.js'
import ShowForThisGroup from 'tasks/nomenclature/new_taxon_name/helpers/showForThisGroup.js'
import componentNames from '../const/componentNames.js'
import { GetterNames } from '../store/getters/getters'
import { RouteNames } from 'routes/routes'
import { Otu } from 'routes/endpoints'

export default {
  components: {
    RadialAnnotator,
    RadialObject,
    QuickForms,
    BrowseTaxon
  },

  props: {
    otu: {
      type: Object,
      required: true
    },
    menu: {
      type: Array,
      required: true
    }
  },

  computed: {
    shortcuts () {
      const keys = {}

      keys[`${platformKey()}+t`] = this.switchNewTaxonName
      keys[`${platformKey()}+b`] = this.switchBrowse
      keys[`${platformKey()}+m`] = this.switchTypeMaterial
      keys[`${platformKey()}+e`] = this.switchComprehensive

      return keys
    },

    taxonName () {
      return this.$store.getters[GetterNames.GetTaxonName]
    },

    isInvalid () {
      return this.taxonName && this.taxonName.id !== this.taxonName.cached_valid_taxon_name_id
    }
  },

  data () {
    return {
      navigation: undefined
    }
  },

  watch: {
    otu: {
      handler (newVal) {
        Otu.breadcrumbs(newVal.id).then(response => {
          this.navigation = response.body
        })
      },
      immediate: true
    }
  },

  created () {
    TW.workbench.keyboard.createLegend(`${platformKey()}+t`, 'Go to new taxon name task', 'Browse OTU')
    TW.workbench.keyboard.createLegend(`${platformKey()}+m`, 'Go to new type specimen', 'Browse OTU')
    TW.workbench.keyboard.createLegend(`${platformKey()}+e`, 'Go to comprehensive specimen digitization', 'Browse OTU')
    TW.workbench.keyboard.createLegend(`${platformKey()}+b`, 'Go to browse nomenclature', 'Browse OTU')
  },

  methods: {
    loadOtu (event) {
      window.open(`/tasks/otus/browse?otu_id=${event.id}`, '_self')
    },

    switchBrowse () {
      this.$refs.browseTaxon.redirect()
    },

    switchNewTaxonName () {
      window.open(`/tasks/nomenclature/new_taxon_name?taxon_name_id=${this.otu.taxon_name_id}`, '_self')
    },

    switchTypeMaterial () {
      window.open(`/tasks/type_material/edit_type_material?taxon_name_id=${this.otu.taxon_name_id}`, '_self')
    },

    switchComprehensive () {
      window.open(`/tasks/accessions/comprehensive?taxon_name_id=${this.otu.taxon_name_id}`, '_self')
    },

    showForRanks (section) {
      const componentSection = Object.values(componentNames()).find(item => item.title === section)
      const rankGroup = componentSection.rankGroup

      return rankGroup ? this.taxonName ? ShowForThisGroup(rankGroup, this.taxonName) : componentSection.otu : true
    },
    openValid () {
      window.open(`${RouteNames.BrowseOtu}?taxon_name_id=${this.taxonName.cached_valid_taxon_name_id}`)
    }
  }

}
</script>

<style lang="scss" scoped>
  .header-bar {
    margin-left: -15px;
    margin-right: -15px;
  }
  .container {
    margin: 0 auto;
    width:1240px;
  }
  .breadcrumb_list {
    margin-bottom: 32px;
  }

  .dropdown {
    display: none;
    position: absolute;
    padding: 12px;
  }

  .dropdown-otu:hover {
    .dropdown {
      display: block;
    }
  }
</style>