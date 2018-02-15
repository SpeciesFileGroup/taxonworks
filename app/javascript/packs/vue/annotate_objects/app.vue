<template>
  <ul>
    <li
            v-for="label, key in list"
            @click="selectType(key)">
      <label>
        <input
                name="annotation-type"
                type="radio"
                :value="key"
                @click="selectType(key)">
        <span
                class="new-combination-rank-list-taxon-name"
                v-html="label"/>
      </label>
    </li>
    <ul>
</template>

<script>
  export default {
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
        this.$emit('select', type)
      }
    }
  }
</script>