<template>
  <div>
    <div class="flex-separate middle">
      <h1>Browse Annotations</h1>
      <span
        @click="resetApp"
        class="reload-app"
        data-icon="reset">Reset
      </span>
    </div>
    <spinner
      v-if="isLoading"
      full-screen
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"/>
    <div class="flexbox">
      <div class="annotation_type separate-right">
        <h2>Annotation type</h2>
        <annotation-types v-model="filter.annotation_type"/>
      </div>
      <div class="annotation_on separate-right separate-left">
        <h2>On</h2>
        <annotation-on
          v-model="filter.model"
          :annotation-type="filter.annotation_type"/>
      </div>
      <div class="annotation_for separate-right separate-left">
        <h2>For</h2>
        <annotation-for
          v-model="filter.selected_for"
          :select-options-url="filter.annotation_type.select_options_url"
          :all-select-option-url="filter.annotation_type.all_select_option_url"
          :on-model="filter.model"/>
      </div>
      <div class="annotation_by separate-right separate-left">
        <h2>By</h2>
        <annotation-by v-model="filter.selected_by"/>
      </div>
      <div class="annotation_dates separate-right separate-left">
        <h2>When</h2>
        <annotation-dates v-model="filter.annotation_dates"/>
      </div>
      <div class="annotation_logic separate-left">
        <h2>Place result</h2>
        <annotation-logic v-model="filter.annotation_logic"/>
      </div>
    </div>
    <button
      class="button normal-input button-default separate-bottom"
      @click="processResult()"
      :disabled="submitAvailable"
      type="submit">Submit
    </button>
    <request-bar
      class="separate-top"
      :list="resultList"
      :type="filter.annotation_type.type"
      :url="request.url"
      :total="request.total"/>

    <div
      class="flex-separate margin-medium-bottom margin-medium-top">
      <pagination-component
        v-if="pagination && resultList.length"
        @nextPage="processResult"
        :pagination="pagination"/>
      <div
        v-if="resultList.length"
        class="horizontal-left-content">
        <span
          class="horizontal-left-content">
          {{ recordsAtCurrentPage }} - 
          {{ recordsAtNextPage }} of {{ pagination.total }} records.
        </span>
        <div class="margin-small-left">
          <select v-model="per">
            <option
              v-for="records in maxRecords"
              :key="records"
              :value="records">
              {{ records }}
            </option>
          </select>
          records per page.
        </div>
      </div>
    </div>
    <view-list
      :list="resultList"/>
  </div>
</template>
<script>

  //TODO: Make a main filter component and move each annotator filter there.
import AnnotationTypes from './components/annotation_types'
import AnnotationOn from './components/annotation_on'
import AnnotationFor from './components/annotation_for'
import AnnotationDates from './components/annotation_dates'
import AnnotationLogic from './components/annotation_logic'
import AnnotationBy from './components/annotation_by'
//
import ViewList from './components/view/list.vue'
import RequestBar from './components/view/requestBar.vue'

import Spinner from 'components/spinner.vue'
import AjaxCall from 'helpers/ajaxCall'
import PaginationComponent from 'components/pagination'
import GetPagination from 'helpers/getPagination'

export default {
  components: {
    AnnotationBy,
    AnnotationTypes,
    AnnotationFor,
    AnnotationOn,
    AnnotationDates,
    AnnotationLogic,
    ViewList,
    RequestBar,
    Spinner,
    PaginationComponent
  },

  data () {
    return {
      filter: this.resetFilter(),
      isLoading: false,
      resultList: [],
      request: {
        url: '',
        total: 0
      },
      for: {
        tags: 'keyword_id',
        data_attributes: 'controlled_vocabulary_term_id',
        confidences: 'confidence_level_id',
      },
      per: 500,
      pagination: undefined,
      maxRecords: [50, 100, 250, 500, 1000]
    }
  },

  computed: {
    submitAvailable () {
      return !this.filter.annotation_type.type || !this.filter.model
    },

    recordsAtCurrentPage () {
      return ((this.pagination.paginationPage - 1) * this.pagination.perPage) || 1
    },

    recordsAtNextPage () {
      const recordsCount = this.pagination.paginationPage * this.pagination.perPage
      return recordsCount > this.pagination.total ? this.pagination.total : recordsCount
    }
  },

  watch: {
    per () {
      this.processResult()
    }
  },

  methods: {
    processResult ({ page } = {}) {
      const params = {
        on: [this.filter.model],
        by: Object.values(this.filter.selected_by).map(item => item.user_id),
        created_after: this.filter.annotation_dates.after,
        created_before: this.filter.annotation_dates.before,
        per: this.per,
        page
      }
      params[this.for[this.filter.annotation_type.type]] = this.filter.selected_for
      this.isLoading = true

      AjaxCall('get', `/${this.filter.annotation_type.type}.json`, { params: params }).then(response => {
        this.pagination = GetPagination(response)
        if (this.filter.annotation_logic === 'replace') {
          this.resultList = response.body
        } else {
          let concat = response.body.concat(this.resultList)

          concat = concat.filter((item, index, self) =>
            index === self.findIndex((i) => (
              i.id === item.id && i.type === item.type
            ))
          )
          this.resultList = concat
        }

        this.request.url = response.request.responseURL
        this.request.total = response.body.length
        this.isLoading = false
      })
    },

    resetApp () {
      this.filter = this.resetFilter()
      this.resultList = []
      this.request.url = ''
      this.request.total = 0
    },

    resetFilter () {
      return {
        annotation_type: {
          type: undefined,
          used_on: undefined,
          select_options_url: undefined,
          all_select_option_url: undefined
        },
        annotation_dates: {
          after: undefined,
          before: undefined
        },
        annotation_logic: 'replace',
        selected_type: undefined,
        selected_for: [],
        selected_by: {},
        model: undefined,
        result: 'initial result'
      }
    }
  }
}
</script>
<style lang="scss">
  .reload-app {
    cursor: pointer;
    &:hover {
      opacity: 0.8;
    }
  }
</style>
