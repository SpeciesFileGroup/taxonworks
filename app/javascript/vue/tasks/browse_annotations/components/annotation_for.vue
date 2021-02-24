<template>
  <div>
    <spinner-component v-if="isLoading"/>
    <smart-selector
      class="separate-bottom"
      :options="tabs"
      name="annotation"
      v-model="view"/>
    <template v-if="view">
      <button
        v-for="item in showList[view]"
        :key="item.id"
        type="button"
        :class="{ 'button-default': !(selectedList.hasOwnProperty(item.id))}"
        class="button normal-input biocuration-toggle-button"
        @click="selectFor(item)">
        <span
          :style="{ 'background-color': item.css_color }"
          v-html="item.object_tag"/>
      </button>
    </template>
  </div>
</template>

<script>
  import smartSelector from 'components/switch.vue'
  import SpinnerComponent from 'components/spinner.vue'
  import OrderSmartSelector from 'helpers/smartSelector/orderSmartSelector'
  import SelectFirstSmartOption from 'helpers/smartSelector/selectFirstSmartOption'
  import AjaxCall from 'helpers/ajaxCall'

  export default {
    components: {
      smartSelector,
      SpinnerComponent
    },
    props: {
      selectOptionsUrl: {
        type: String
      },
      allSelectOptionUrl: {
        type: String
      },
      onModel: {
        type: String
      },
      value: {
        type: Object,
      },
    },
    watch: {
      selectOptionsUrl() {
        this.selectedList = {}   // clear the selected items list
        this.list = {}           // clear the displayable lists
        this.view = undefined    // delelect which view of the displayable list
        this.tabs = []           // clear the tabs in the smart selector
      },
      onModel(newVal) {
        this.selectedList = {}
        if (this.selectOptionsUrl && newVal) { this.getSelectOptions(newVal) }
      }
    },
    computed: {
      showList() {
        return this.list
      }
    },
    data() {
      return {
        list: {},
        tabs: [],
        view: undefined,
        selectedList: {},
        isLoading: false
      }
    },
    methods: {
      selectFor(item) {
        if (this.selectedList.hasOwnProperty(item.id)) {
          this.$delete(this.selectedList, item.id)
        }
        else {
          this.$set(this.selectedList, item.id, item)
        }
        this.$emit('input', this.selectedList)
        this.$emit('selected_for', this.selectedList)
      },
      getSelectOptions(onModel) {
        this.isLoading = true
        AjaxCall('get', this.selectOptionsUrl, { params: { klass: this.onModel } }).then(response => {
          this.tabs = OrderSmartSelector(Object.keys(response.body))
          this.list = response.body
          AjaxCall('get', this.allSelectOptionUrl).then(response => {
            if(response.body.length) {
              this.tabs.push('all')
            }
            this.$set(this.list, 'all', response.body)
            this.view = SelectFirstSmartOption(this.list, this.tabs)
            this.isLoading = false
          })
        })
      }
    }
  }
</script>