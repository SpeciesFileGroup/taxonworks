<template>
  <div>
    <smart-selector 
      :options="tabs"
      name="annotation"
      v-model="view"/>
    <button
      v-for="(label, key) in list"
      :key="key"
      type="button"
      @click="selectFor(key)"
      class="bottom button-submit normal-input biocuration-toggle-button"
      v-html="label"/>
    <span v-for="(item, key) in result" :key="key"> {{ key }} : {{ item }} <br></span>
  </div>
</template>

<script>

  import smartSelector from './smartSelector.vue'

  export default {
    components: {
      smartSelector
    },
    props: {

      value: {
        type: String,
      },

      annotationType: {
        type: Object,
        required: true
      },
    },
    watch: {
      value(newVal) {
        this.getResult(newVal)
      },
      annotationType: {
        handler(newVal) {
          if(newVal) {
            // Here is where you trigger the method to populate the smart selector
            // you will take the values of type and used_on from annotationType object.
            // annotationType.type
            // aanotationType.used_on
            this.smartSelector = newVal.select_options_url;
          }
        },
        deep: true
      }
    },
    data() {
      return {
        list: {},
        tabs: ['quick', 'recent', 'pinboard', 'all'], //This is hard coded for now, but should be taking from the entry point.
        view: undefined,
        result: undefined
      }
    },
    // mounted: function () {
    //   this.$http.get('/tasks/browse_annotations/get_for_list').then(response => {
    //     console.log(response); // this is necessary to show traffic?
    //     this.list = response.body;
    //   })
    // },

    methods: {
      selectFor(type) {
        this.$emit('input', type.valueOf())
      },
      getResult(newVal) {
        this.$http.post('/tasks/browse_annotations/annotation_for', {annotationFor: newVal}).then(response => {
          // console.log(response);
          this.$emit('for_selected', response.body);
          this.$emit('result', response.body);
          this.result = response.body;
        })
      }
    }
  }
</script>