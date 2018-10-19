<template>
  <div class="find-taxonname-picker">
    <ul
      class="no_bullets find-taxonname-list"
      v-if="json.length > 0">
      <li
        v-for="(item, index) in json"
        v-if="maxResults == 0 || index < maxResults">
        <a
          target="_blank"
          :href="makeUrl(item.id)"
          v-html="item[label]"/>
      </li>
    </ul>
    <spinner
      legend="Checking for identical spellings"
      :legend-style="{ fontSize: '14px', color: '#444', textAlign: 'center', paddingTop: '20px'}"
      v-if="spinner"/>
  </div>
</template>

<script>

import Spinner from '../../../components/spinner.vue'

export default {
  components: {
    Spinner
  },
  props: {
    url: {
      type: String,
      required: true
    },
    search: {
      required: true
    },
    label: {
      type: String
    },
    time: {
      type: String,
      default: '500'
    },
    maxResults: {
      type: Number,
      default: 10
    },
    addParams: {
      type: Object
    },
    param: {
      type: String,
      default: 'value'
    },
    taxon: {
      type: Object,
      default: undefined
    }
  },
  data: function () {
    return {
      json: [],
      spinner: false,
      getRequest: 0
    }
  },
  watch: {
    search: function (newVal, oldVal) {
      if (oldVal != undefined) {
        this.checkTime()
      }
    },
    taxon: function (val) {
      this.json = []
    }
  },
  methods: {
    ajaxUrl: function () {
      var tempUrl = this.url + '?' + this.param + '=' + this.search
      var params = ''
      if (this.addParams) {
        Object.keys(this.addParams).forEach((key) => {
          params += `&${key}=${this.addParams[key]}`
        })
      }
      return tempUrl + params
    },
    makeUrl: function (id) {
      return '/tasks/nomenclature/new_taxon_name/' + id
    },
    sendItem: function (item) {
      this.$emit('getItem', item)
    },
    clearResults: function () {
      this.json = []
    },
    checkTime: function () {
      var that = this
      if (this.getRequest) {
        clearTimeout(this.getRequest)
      }
      this.getRequest = setTimeout(function () {
        that.update()
      }, that.time)
    },
    update: function () {
      if (this.search.length < Number(this.min)) return
      this.spinner = true
      this.clearResults()
      this.$http.get(this.ajaxUrl(), {
        before (request) {
          if (this.previousRequest) {
            this.previousRequest.abort()
          }
          this.previousRequest = request
        }
      }).then(response => {
        this.json = response.body
        if(Array.isArray(response.body))
          this.json.sort(((a, b) => {
            if (a.label < b.label)
              return -1;
            if (a.label > b.label)
              return 1;
            return 0;
          }))
        this.spinner = false
        this.$emit('existing', this.json)
      }, response => {
      })
    },
    activeClass: function activeClass (index) {
      return {
        active: this.current === index
      }
    },
    activeSpinner: function () {
      return 'ui-autocomplete-loading'
    }
  }
}
</script>

<style lang="scss" scoped>
  .find-taxonname-picker {
    min-height:100px;
  }
  .find-taxonname-list {
    max-height: 200px;
    overflow-y: scroll;
    margin-top: 1.2em;
    box-sizing: border-box;
    min-width: 250px;
    border: 1px solid #f5f5f5;
    padding: 12px;
    border-radius: 3px;
    .header {
      border-bottom: 1px solid #f5f5f5;
    }
    .body {
      padding: 12px;
    }

    li a {
      transition: padding 0.3s ease;
      cursor: pointer;
    }
    li a:hover {
      padding-left: 12px;
      transition: padding 0.3s ease;
    }
  }
</style>
