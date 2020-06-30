<template>
  <div
    v-if="display"
    id="otu_panel"
    class="panel content">
    <autocomplete
      url="/otus/autocomplete"
      min="3"
      param="term"
      placeholder="Find OTU"
      @getItem="loadOtu($event.id)"
      label="label_html"/>
  </div>
</template>

<script>

  import Autocomplete from 'components/autocomplete.vue'
  import { GetterNames } from '../store/getters/getters'
  import { MutationNames } from '../store/mutations/mutations'
  import AjaxCall from 'helpers/ajaxCall'

  export default {
    name: 'PanelTop',
    components: {
      Autocomplete
    },
    computed: {
      display() {
        return this.$store.getters[GetterNames.ActiveOtuPanel]
      }
    },
    mounted: function () {
      this.getParams()
    },
    methods: {
      loadOtu(id) {
        AjaxCall('get', `/otus/${id}.json`).then(response => {
          this.$store.commit(MutationNames.SetOtuSelected, response.body)
        })        
      },
      getParams() {
        var url = new URL(window.location.href);
        var otuId = url.searchParams.get("otu_id");
        if(otuId != null && Number.isInteger(Number(otuId))) {
          this.loadOtu(otuId)
        }
      }
    }
  }
</script>
