<template>
  <div>
    <smart-selector
      name="geography"
      v-model="view"
      :add-option="moreOptions"
      :options="options"/>
  </div>
</template>

<script>

  import SmartSelector from '../../../../../../components/switch.vue'
  import { GetGeographicSmartSelector } from '../../../../request/resources.js'

  export default {
    components: {
      SmartSelector
    },
    data() {
      return {
        moreOptions: ['Look back', 'Search'],
        options: [],
        view: undefined,
        lists: []
      }
    },
    mounted() {
      this.GetSmartSelector()
    },
    methods: {
      GetSmartSelector() {
        GetGeographicSmartSelector().then(response => {
          let result = response
          Object.keys(result).forEach(key => (!result[key].length) && delete result[key])
          this.options = Object.keys(result)
          if(Object.keys(result).length) {
            this.view = Object.keys(result)[0]
          }
          this.lists = response        
        })
      }
    }
  }
</script>
