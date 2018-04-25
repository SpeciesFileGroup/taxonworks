<template>
  <div>
    <smart-selector 
      :options="tabs"
      name="annotation"
      :add-option="['all']"
      v-model="view"/>
    <button
      v-if="view"
      v-for="item in list[view]"
      :key="item.id"
      type="button"
      @click="selectFor(item)"
      class="bottom button-submit normal-input biocuration-toggle-button"
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
        type: Number,
      },
    },
    watch: {
      onModel(newVal) {
        if(this.selectOptionsUrl)
          this.getSelectOptions(newVal)
      },
    },
    data() {
      return {
        list: {},
        tabs: [],
        view: undefined,
        result: undefined
      }
    },
    methods: {
      selectFor(type) {
        this.$emit('input', type)
      },
      getSelectOptions(onModel) {
        this.$http.get(this.selectOptionsUrl, { params: { klass: this.onModel } }).then( response => {
          this.tabs = Object.keys(response.body);
          console.log(Object.keys(response.body));
          this.list = response.body;
          console.log(response.body);
        this.$http.get(this.allSelectOptionUrl).then( response => {
          this.list['all'] = response.body;
          console.log(response.body);
        })
        })
      },
      getResult(newVal) {
        this.$http.post('/tasks/browse_annotations/annotation_for', {annotationFor: newVal}).then(response => {
          this.$emit('for_selected', response.body);
          this.$emit('result', response.body);
          this.result = response.body;
        })
      }
    }
  }
</script>