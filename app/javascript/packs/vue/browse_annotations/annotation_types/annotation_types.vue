<template>
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
</template>

<script>
  export default {
    props: {
      value: {
        type: String,
      }
    },
    data() {
      return {
        list: {
          tags: 'Tags (by Keyword)',
          data_attributes: 'Data attribues (by Predicates)',
          confidence: 'Confidence (by Confidence Level)'
        }
      }
    },
    methods: {
      selectType(type) {
        this.$emit('input', type.valueOf())
      }
    }
  }
</script>