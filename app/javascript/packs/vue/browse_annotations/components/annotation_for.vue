<template>
    <div>
      <button
        v-for="label, key in list"
        type="button"
        @click="selectFor(key)"
        class="bottom button-submit normal-input biocuration-toggle-button"
        v-html="label"/>
      <span v-for="(item, key) in result"> {{ key }} : {{ item }} <br></span>
    </div>
</template>

<script>
  export default {
    props: {
      value: {
        type: String,
      }
    },
    watch: {
      value(newVal) {
        this.getResult(newVal)
      }
    },
    data() {
      return {
        list: {},
        result: undefined
      }
    },
    mounted: function () {
      this.$http.get('/tasks/browse_annotations/get_for_list').then(response => {
        console.log(response); // this is necessary to show traffic?
        this.list = response.body;
      })
    },
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