<template>
  <div>
    <h2>Cite Taxon Name</h2>
    <smart-selector
        :options="tabs"
        name="citation"
        :add-option="moreOptions"
        v-model="view"/>
    <autocomplete
        v-if="view == 'Search'"
        url="/otus/autocomplete"
        min="2"
        param="term"
        placeholder="Search for a taxon"
        event-send="otupicker"
        label="label"
        :autofocus="true" />
    <button
        v-if="view"
        v-for="item in showList[view]"
        :key="item.id"
        type="button"
        :class="{ 'button-default': !(selectedList.hasOwnProperty(item.id))}"
        class="button normal-input biocuration-toggle-button"
        @click="selectFor(item)"
        v-html="item.name"/>
  </div>
</template>
<script>
  import SmartSelector from './smartSelector.vue'
  import Autocomplete from '../../../../components/autocomplete.vue'
  export default {
    components: {
      SmartSelector,
      Autocomplete
    },
    props: {
      // selectOptionsUrl: {
      //   type: String
      // },
      // allSelectOptionUrl: {
      //   type: String
      // },
      value: {
        type: Object,
      },
    },
    data() {
      return {
        list: {},
        tabs: [],//,[],
        moreOptions: ['Search'],
        view: undefined,
        selectedList: {}
      }
    },
    computed: {
      showList() {
        return this.list
      }
    },
    mounted: function() {
      this.$http.get('/taxon_names/select_options').then(response => {
        this.tabs = Object.keys(response.body);
        this.list = response.body;
      })
    }
  }

</script>