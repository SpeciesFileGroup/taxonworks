<template>
  <div>
    <smart-selector
        :options="tabs"
        name="annotation"
        :add-option="['all']"
        v-model="view"/>
    <button
        v-if="view"
        v-for="item in showList[view]"
        :key="item.id"
        type="button"
        :class="{ ' button-submit': (selectedList.hasOwnProperty(item.id))}"
        class="button normal-input button-default biocuration-toggle-button"
        @click="selectFor(item)"
        v-html="item.name"/>
  </div>
</template>

<script>
  import smartSelector from './smartSelector.vue'

  export default {
    components: {
      smartSelector
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
        this.selectedList = {}
        this.list = {}
        this.view = undefined
        this.tabs = []
      },
      onModel(newVal) {
        this.selectedList = {}
        if (this.selectOptionsUrl)
          this.getSelectOptions(newVal)
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
        result: undefined,
        selectedList: {}
      }
    },
    methods: {
      selectFor(item) {
        if (this.selectedList.hasOwnProperty(item.id)) {
          this.$delete(this.selectedList, item.id)
        }
        else {
          this.$set(this.selectedList, item.id, item);
        }
        this.$emit('input', this.selectedList);
      },
      getSelectOptions(onModel) {
        this.$http.get(this.selectOptionsUrl, {params: {klass: this.onModel}}).then(response => {
          this.tabs = Object.keys(response.body);
          console.log(Object.keys(response.body));
          this.list = response.body;
          console.log(response.body);
          this.$http.get(this.allSelectOptionUrl).then(response => {
            this.$set(this.list, 'all', response.body);
            console.log(response.body);
          })
        })
      }
    }
  }
</script>