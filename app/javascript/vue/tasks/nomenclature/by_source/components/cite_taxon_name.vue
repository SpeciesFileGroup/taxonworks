<template>
  <div>
    <h3>Cite Taxon Name</h3>
    <smart-selector
        :options="tabs"
        name="citation"
        :add-option="moreOptions"
        v-model="view"/>
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
      value: {
        type: Object,
      },
    },
    data() {
      return {
        list: {},
        tabs: [],
        moreOptions: [],
        view: undefined,
        selectedList: {}
      }
    },
  }

</script>