<template>
  <div>
    <ul>
      <li v-for="(label, key) in list">
        <label @click="selectType(key)">
          <input
            :checked="value === key"
            name="annotation-type"
            type="radio"
            :value="key">
          <span
            class="new-combination-rank-list-taxon-name"
            v-html="label"/>
        </label>
      </li>
    </ul>
    <span v-for="(item, key) in result"> {{ key }} : {{ item }} </span>
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
        list: {
          tags: 'Tags (by Keyword)',
          data_attributes: 'Data attribues (by Predicates)',
          confidence: 'Confidence (by Confidence Level)'
        },
        result: undefined
      }
    },
    methods: {
      selectType(type) {
        this.$emit('input', type.valueOf())
      },
      getResult(newVal) {
        // this.$http.post('/tasks/browse_annotations/get_type', {json: newVal}).then(response => {
        //   this.result = response.body
        this.$http.post('/tasks/browse_annotations/get_type', {annotationType: newVal}).then(response => {
          console.log(response);
          this.$emit('annotation_type_selected', response)
        })
      }
    }
  }
</script>