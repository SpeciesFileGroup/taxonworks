<template>
  <div id="browse-otu">
    <spinner-component
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"
      v-if="isLoading"
    />
    <div class="flex-separate middle container">
      <h1>Browse taxa</h1>
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
        :otu="otu" />
      <div class="separate-top separate-bottom"></div>
      <draggable
        class="container"
        handle=".handle"
        v-model="section">
        <component
          class="separate-bottom full_width"
          v-for="component in section"
          :key="component"
          :otu="otu"
          :is="component"/>
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
import NomenclatureHistory from './components/NomenclatureHistory'
import CollectingEvents from './components/CollectingEvents'
import CollectionObjects from './components/CollectionObjects'
import TypeSpecimens from './components/specimens/Type'
import CommonNames from './components/CommonNames'
import Descendants from './components/descendants'
import Autocomplete from 'components/autocomplete'
import SearchOtu from './components/SearchOtu'
import Draggable from 'vuedraggable'
import { ActionNames } from './store/actions/actions'

import { GetOtu, GetOtus, GetNavigationOtu } from './request/resources.js'

export default {
  components: {
    SearchOtu,
    HeaderBar,
    ImageGallery,
    SpinnerComponent,
    ContentComponent,
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
    Descendants
  },
  data () {
    return {
      isLoading: false,
      otu: undefined,
      otus: [],
      navigate: undefined,
      section: ['NomenclatureHistory', 'Descendants', 'ImageGallery', 'CommonNames', 'TypeSpecimens', 'CollectionObjects', 'ContentComponent', 'AssertedDistribution', 'BiologicalAssociations', 'AnnotationsComponent', 'CollectingEvents']
    }
  },
  watch: {
    otu: {
      handler (newVal) {
        this.$store.dispatch(ActionNames.LoadInformation, newVal.id)
      },
      deep: true
    }
  },
  mounted () {
    let urlParams = new URLSearchParams(window.location.search)

    let otuId = urlParams.get('otu_id') ? urlParams.get('otu_id') : location.pathname.split('/')[4]
    let taxonId = urlParams.get('taxon_name_id')
    if (/^\d+$/.test(otuId)) {
      GetOtu(otuId).then(response => {
        this.otu = response.body
        this.$store.dispatch(ActionNames.LoadCollectionObjects, this.otu.id)
        this.$store.dispatch(ActionNames.LoadCollectingEvents, this.otu.id)
        this.isLoading = false
      })
      GetNavigationOtu(otuId).then(response => {
        this.navigate = response.body
      })
    } else if (taxonId) {
      GetOtus(taxonId).then(response => {
        if (response.body.length === 1) {
          this.otu = response.body[0]
          this.$store.dispatch(ActionNames.LoadCollectionObjects, this.otu.id)
          this.$store.dispatch(ActionNames.LoadCollectingEvents, this.otu.id)
        } else {
          this.otus = response.body
        }
        this.isLoading = false
      })
    } else {
      this.isLoading = false
    }
  },
  methods: {
    loadOtu (event) {
      window.open(`/tasks/otus/browse?otu_id=${event.id}`, '_self')
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
      color: #888;
      font-size: 14px;
    }
  }
</style>