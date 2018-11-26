
<template>
  <div>
    <h3>Collecting event</h3>
    <autocomplete
      url="/collecting_events/autocomplete"
      min="2"
      label="label_html"
      placeholder="Select a place name"
      :autofocus="true"
      @getItem="sendCollectingEvent"
      display="label"
      param="term"/>
    <smart-selector
      :options="tabs"
      name="collecting_event"
      :add-option="moreOptions"
      v-model="view"/>
  </div>
</template>

<script>
  import SmartSelector from 'components/switch.vue'
  import Autocomplete from 'components/autocomplete.vue'

  export default {
    components: {
      SmartSelector,
      Autocomplete
    },
    data() {
      return {
        tabs: [],
        moreOptions: ['Search'],
        view: undefined
      }
    },
    methods: {
      sendCollectingEvent(item) {
        // this.selected=item.id;
        this.$emit('itemid', item.id)
      }
    },
    mounted: function() {
      this.$http.get('/collecting_events/select_options').then(response => {
        this.tabs = Object.keys(response.body);
        this.list = response.body;
        if(this.tabs.length) {
          this.view = this.tabs[0]
        }
      })
    }
  }
</script>
