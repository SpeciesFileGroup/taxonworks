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
        v-for="item in list[view]"
        :key="item.id"
        type="button"
        :class="{ 'button-default': !selected.includes(item.id)}"
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

    modelValue: {
      type: Object
    },
  },

  emits: [
    'update:modelValue',
    'selected_for'
  ],

  computed: {
    selected: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  watch: {
    selectOptionsUrl() {
      this.selected = []
      this.list = {}           // clear the displayable lists
      this.view = undefined    // delelect which view of the displayable list
      this.tabs = []           // clear the tabs in the smart selector
    },

    onModel (newVal) {
      this.selected = []
      if (this.selectOptionsUrl && newVal) { this.getSelectOptions(newVal) }
    }
  },

  data () {
    return {
      list: {},
      tabs: [],
      view: undefined,
      isLoading: false
    }
  },

  methods: {
    selectFor (item) {
      const index = this.selected.findIndex(id => item.id === id)

      if (index > -1) {
        this.selected.splice(index, 1)
      } else {
        this.selected.push(item.id)
      }
    },

    getSelectOptions (onModel) {
      this.isLoading = true
      AjaxCall('get', this.selectOptionsUrl, { params: { klass: this.onModel, target: this.onModel } }).then(response => {
        this.tabs = OrderSmartSelector(Object.keys(response.body))
        this.list = response.body
        AjaxCall('get', this.allSelectOptionUrl).then(response => {
          if (response.body.length) {
            this.tabs.push('all')
          }
          this.list['all'] = response.body
          this.view = SelectFirstSmartOption(this.list, this.tabs)
          this.isLoading = false
        })
      })
    }
  }
}
</script>