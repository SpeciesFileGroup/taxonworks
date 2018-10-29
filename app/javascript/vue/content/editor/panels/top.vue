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
      event-send="otu_picker"
      label="label_html"/>
  </div>
</template>

<script>

  import Autocomplete from 'components/autocomplete.vue'
  import { GetterNames } from '../store/getters/getters'
  import { MutationNames } from '../store/mutations/mutations'

  export default {
    name: 'PanelTop',
    computed: {
      display() {
        return this.$store.getters[GetterNames.ActiveOtuPanel]
      }
    },
    mounted: function () {
      let that = this
      this.$on('otu_picker', function (item) {
        that.$http.get('/otus/' + item.id).then(response => {
          that.$store.commit(MutationNames.SetOtuSelected, response.body)
        })
      })
    },
    components: {
      Autocomplete
    }
  }
</script>
