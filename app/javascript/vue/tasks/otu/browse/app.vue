<template>
  <div id="browse-otu">
    <spinner-component
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"
      v-if="isLoading"
    />
    <header-bar
      :otu="otu" />
    <div class="container">
      <component
        class="separate-bottom full_width"
        v-for="component in section"
        :key="component"
        :otu="otu"
        :is="component"/>
    </div>
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

import { GetOtu } from './request/resources.js'

export default {
  components: {
    HeaderBar,
    ImageGallery,
    SpinnerComponent,
    ContentComponent,
    AssertedDistribution,
    BiologicalAssociations,
    AnnotationsComponent,
    NomenclatureHistory,
    CollectingEvents
  },
  data() {
    return {
      isLoading: false,
      otu: undefined,
      section: ['ImageGallery', 'NomenclatureHistory', 'ContentComponent', 'AssertedDistribution', 'BiologicalAssociations', 'AnnotationsComponent', 'CollectingEvents']
    }
  },
  mounted() {

    let otuId = location.pathname.split('/')[4]
      if (/^\d+$/.test(otuId)) {
        GetOtu(otuId).then(response => {
          this.otu = response.body
          this.isLoading = false
        })
      } else {
        this.isLoading = false
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