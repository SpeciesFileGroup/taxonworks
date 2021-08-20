<template>
  <h3>Citations ({{ citations.length }})</h3>
  <ul
    v-if="citations.length"
    class="taxonomic_history">
    <template 
      v-for="(item, index) in citations"
      :key="index">
      <li v-if="item.label_html">
        <span v-html="item.label_html"/>
      </li>
    </template>
  </ul>
</template>

<script>
export default {
  props: {
    citations: {
      type: Array,
      required: true
    }
  }
}
</script>
