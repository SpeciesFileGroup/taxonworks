<template>
  <div class="panel vue-filter-container">
    <div class="flex-separate content middle action-line">
      <span>Filter</span>
      <span
        data-icon="reset"
        class="cursor-pointer"
        v-shortkey="[getMacKey, 'r']"
        @shortkey="resetFilter"
        @click="resetFilter">Reset
      </span>
    </div>
    <spinner-component
      :full-screen="true"
      legend="Searching..."
      :logo-size="{ width: '100px', height: '100px'}"
      v-if="searching"
    />

    <spinner-component
      :full-screen="true"
      :legend="`Building ${ DWCACount } ... ${ DWCASearch.length } unindexed records`"
      :logo-size="{ width: '100px', height: '100px'}"
      v-if="loadingDWCA"
    />
    <div class="content">
      <button
        class="button button-default normal-input full_width"
        type="button"
        v-shortkey="[getMacKey, 'f']"
        @shortkey="searchOtus(parseParams)"
        @click="searchOtus(parseParams)">
        Search
      </button>
      <geographic-areas v-model="params.geographic"/>
      <taxon-name-component v-model="params.base.taxon_name_ids"/>
      <author-component v-model="params.author"/>
      <citations-component
        title="Citations"
        v-model="params.base.citations"/>
      <with-component
        v-for="(item, key) in params.with"
        :key="key"
        :title="key"
        v-model="params.with[key]"/>
    </div>
  </div>
</template>

<script>

import SpinnerComponent from 'components/spinner'
import GetMacKey from 'helpers/getMacKey.js'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { GetOtus } from '../request/resources'

import TaxonNameComponent from './filters/TaxonName'
import GeographicAreas from '../../../collection_objects/filter/components/filters/geographic'
import CitationsComponent from '../../../taxon_names/filter/components/filters/citations'
import WithComponent from '../../../observation_matrices/dashboard/components/filters/with'
import AuthorComponent from './filters/authors.vue'

export default {
  components: {
    AuthorComponent,
    SpinnerComponent,
    GeographicAreas,
    TaxonNameComponent,
    CitationsComponent,
    WithComponent
  },
  computed: {
    getMacKey () {
      return GetMacKey()
    },
    parseParams () {
      return Object.assign({}, this.params.settings, this.filterEmptyParams(this.params.author), this.params.base, this.params.with)
    },
    emptyParams () {
      if (!this.params) return
      return !this.params.base.otu_id &&
        !this.params.base.biological_association_ids.length &&
        !this.params.base.taxon_name_relationship_ids.length &&
        !this.params.base.taxon_name_classification_ids.length &&
        !this.params.base.asserted_distribution_ids.length &&
        !this.params.base.data_attributes_attributes.length
    }
  },
  data () {
    return {
      params: this.initParams(),
      result: [],
      searching: false,
      perRequest: 10,
      coList: [],
      usersList: [],
      loadingDWCA: false,
      DWCACount: 0,
      DWCASearch: 0
    }
  },
  mounted () {
    const urlParams = URLParamsToJSON(location.href)
    if (Object.keys(urlParams).length) {
      urlParams.geo_json = urlParams.geo_json ? JSON.stringify(urlParams.geo_json) : []
      this.searchOtus(urlParams)
    }
  },
  methods: {
    resetFilter () {
      this.$emit('reset')
      this.params = this.initParams()
    },
    searchOtus (params) {
      this.searching = true

      GetOtus(params).then(response => {
        this.result = response.body
        this.$emit('result', this.result)
        this.$emit('urlRequest', response.request.responseURL)
        this.$emit('pagination', response)
        this.searching = false
        if (this.result.length === 500) {
          TW.workbench.alert.create('Results may be truncated.', 'notice')
        }
        const urlParams = new URLSearchParams(response.request.responseURL.split('?')[1])
        history.pushState(null, null, `/tasks/otus/filter/index?${urlParams.toString()}`)
      }, () => {
        this.searching = false
      })
    },
    initParams () {
      return {
        settings: {
          per: 500,
          page: 1
        },
        author: {
          author: undefined,
          exact_author: undefined,
          author_ids: []
        },
        base: {
          taxon_name_ids: [],
          biological_association_ids: [],
          taxon_name_relationship_ids: [],
          taxon_name_classification_ids: [],
          asserted_distribution_ids: [],
          data_attributes_attributes: [],
          citations: undefined
        },
        geographic: {
          geo_json: [],
          radius: undefined,
          spatial_geographic_areas: undefined,
          geographic_area_ids: []
        },
        with: {
          biological_associations: undefined,
          asserted_distributions: undefined,
          daterminations: undefined,
          depictions: undefined,
          observations: undefined,
        }
      }
    },
    loadPage(page) {
      this.params.settings.page = page
      this.searchOtus(this.parseParams)
    },
    filterEmptyParams(object) {
      let keys = Object.keys(object)
      keys.forEach(key => {
        if(object[key] === '') {
          delete object[key]
        }
      })
      return object
    },
    flatObject(object, key) {
      let tmp = Object.assign({}, object, object[key])
      delete tmp[key]
      return tmp
    }
  }
}
</script>
<style scoped>
>>> .btn-delete {
    background-color: #5D9ECE;
  }
</style>
