<template>
  <div id="browse-otu">
    <select-otu
      :otus="otuList"
      @selected="loadOtu"/>
    <spinner-component
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"
      v-if="isLoading"
    />
    <div class="flex-separate middle container">
      <h1>Browse OTUs</h1>
      <div class="horizontal-left-content">
        <ul
          v-if="navigate"
          class="no_bullets">
          <li v-for="item in navigate.previous_otus">
            <a :href="`/tasks/otus/browse?otu_id=${item.id}`" v-html="item.object_tag"/>
          </li>
        </ul>
        <template v-if="otu">
          <autocomplete
            class="float_right separate-left separate-right"
            url="/otus/autocomplete"
            placeholder="Search a otu"
            param="term"
            :clear-after="true"
            @getItem="loadOtu"
            label="label_html"/>
          <ul
            v-if="navigate"
            class="no_bullets">
            <li v-for="item in navigate.next_otus">
              <a :href="`/tasks/otus/browse?otu_id=${item.id}`" v-html="item.object_tag"/>
            </li>
          </ul>
        </template>
      </div>
    </div>
    <template v-if="otu">
      <header-bar
        class="container separate-bottom"
        :menu="menu"
        :otu="otu" />
      <div class="separate-top separate-bottom"></div>
      <draggable
        class="container"
        handle=".handle"
        :item-key="element => element"
        v-model="preferences.sections">
        <template #item="{ element }">
          <component
            v-if="showForRanks(componentNames[element])"
            class="separate-bottom full_width"
            :title="componentNames[element].title"
            :status="componentNames[element].status"
            :otu="otu"
            :is="element"/>
        </template>
      </draggable>
    </template>
    <search-otu
      v-else
      class="container"
      @onOtuSelect="loadOtu"/>
  </div>
</template>

<script>

import HeaderBar from './components/HeaderBar'
import SpinnerComponent from 'components/spinner'
import ImageGallery from './components/gallery/Main'
import ContentComponent from './components/Content'
import AssertedDistribution from './components/AssertedDistribution'
import BiologicalAssociations from './components/BiologicalAssociations'
import AnnotationsComponent from './components/Annotations'
import NomenclatureHistory from './components/timeline/Timeline.vue'
import CollectingEvents from './components/CollectingEvents'
import CollectionObjects from './components/CollectionObjects'
import TypeSpecimens from './components/specimens/Type'
import TypeSection from './components/TypeSection.vue'
import CommonNames from './components/CommonNames'
import DescriptionComponent from './components/Description.vue'
import Descendants from './components/descendants'
import Autocomplete from 'components/ui/Autocomplete'
import SearchOtu from './components/SearchOtu'
import Draggable from 'vuedraggable'
import SelectOtu from './components/selectOtu'
import { ActionNames } from './store/actions/actions'
import { TaxonName, Otu, User } from 'routes/endpoints'
import { GetterNames } from './store/getters/getters'
import { MutationNames } from './store/mutations/mutations'
import COMPONENT_NAMES from './const/componentNames'
import ShowForThisGroup from 'tasks/nomenclature/new_taxon_name/helpers/showForThisGroup.js'

export default {
  components: {
    SearchOtu,
    HeaderBar,
    ImageGallery,
    SpinnerComponent,
    ContentComponent,
    DescriptionComponent,
    AssertedDistribution,
    BiologicalAssociations,
    AnnotationsComponent,
    NomenclatureHistory,
    CollectingEvents,
    CollectionObjects,
    TypeSpecimens,
    CommonNames,
    Autocomplete,
    Draggable,
    Descendants,
    SelectOtu,
    TypeSection
  },
  computed: {
    preferences: {
      get () {
        return this.$store.getters[GetterNames.GetPreferences]
      },
      set (value) {
        this.$store.commit(MutationNames.SetPreferences, value)
      }
    },
    menu () {
      return this.preferences.sections.map(name => this.componentNames[name].title)
    },
    taxonName () {
      return this.$store.getters[GetterNames.GetTaxonName]
    },
    otu () {
      return this.$store.getters[GetterNames.GetCurrentOtu]
    },
    otus () {
      return this.$store.getters[GetterNames.GetOtus]
    }
  },
  data () {
    return {
      isLoading: false,
      navigate: undefined,
      tmp: undefined,
      otuList: [],
      componentNames: COMPONENT_NAMES()
    }
  },
  watch: {
    otus: {
      handler (newVal) {
        this.$store.dispatch(ActionNames.LoadInformation, newVal)
      },
      deep: true
    },
    preferences: {
      handler (newVal, oldVal) {
        if (newVal && JSON.stringify(newVal) !== JSON.stringify(this.tmp)) {
          this.tmp = newVal
          User.update(this.$store.getters[GetterNames.GetUserId], { user: { layout: { browseOtu: newVal } } }).then(response => {
            this.preferences = response.body.preferences.layout?.browseOtu
          })
        }
      },
      deep: true
    }
  },
  created () {
    const urlParams = new URLSearchParams(window.location.search)
    const otuId = urlParams.get('otu_id') ? urlParams.get('otu_id') : location.pathname.split('/')[4]
    const taxonId = urlParams.get('taxon_name_id')

    if (/^\d+$/.test(otuId)) {
      this.$store.dispatch(ActionNames.LoadOtus, otuId).then(() => {
        this.isLoading = false
      })
      Otu.navigation(otuId).then(response => {
        this.navigate = response.body
      })
    } else if (taxonId) {
      TaxonName.otus(taxonId).then(response => {
        if (response.body.length > 1) {
          this.otuList = response.body
        } else {
          this.$store.dispatch(ActionNames.LoadOtus, response.body[0].id).then(() => {
            this.isLoading = false
          })
        }
      })
    } else {
      this.isLoading = false
    }
  },
  methods: {
    loadOtu (event) {
      window.open(`/tasks/otus/browse?otu_id=${event.id}`, '_self')
    },
    updatePreferences () {
      User.update(this.preferences.id, { user: { layout: { [this.keyStorage]: this.componentsOrder } } }).then(response => {
        this.preferences.layout = response.preferences
        this.componentsOrder = response.preferences.layout[this.keyStorage]
      })
    },
    showForRanks (section) {
      const rankGroup = section.rankGroup
      return rankGroup ? this.taxonName ? ShowForThisGroup(rankGroup, this.taxonName) : section.otu : true
    }
  }
}
</script>

<style lang="scss">
  #browse-otu {
    .container {
      margin: 0 auto;
      width: 1240px;
      min-width: auto;
    }
    .section-title {
      text-transform: uppercase;
      font-size: 14px;
    }
    .expand-box {
      width: 24px;
      height: 24px;
      padding: 0px;
      background-size: 10px;
      background-position: center;
    }

    .mark-box {
      width: 10px;
      height: 10px;
      padding: 0px;
    }
  }
</style>
