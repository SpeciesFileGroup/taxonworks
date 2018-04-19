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
    <span
      v-for="(item, key) in result"
      :key="key"> {{ key }} : {{ item }}<br>
    </span>
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
      onModel: {
        type: String
      },
      value: {
        type: String,
      },
    },
    watch: {
      selectOptionsUrl(newVal) {
        this.getSelectOptions(newVal);
      },
    },
    data() {
      return {
        list: {},
        tabs: ['quick', 'recent', 'pinboard', 'all'], //This is hard coded for now, but should be taking from the entry point.
        view: undefined,
        result: undefined
      }
    },
    methods: {
      selectFor(type) {
        this.$emit('input', type.valueOf())
      },
      getSelectOptions(onModel) {
        this.$http.post(this.selectOptionsUrl, {klass: this.onModel}).then( response => {
          this.list = response.body;
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