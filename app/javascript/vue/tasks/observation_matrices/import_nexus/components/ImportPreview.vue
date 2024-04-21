<template>
  <div
    v-if="otus.length || descriptors.length"
    class="preview"
  >
    <em> Linked descriptors or OTUs are matches with existing data. </em>

    <p v-if="otus.length">
      <strong>Taxa:</strong> ({{ otus.length }})
      <ImportList
        :list="otus"
        type_attr="otu"
      />
    </p>
    <p v-else>
      <em>No otus found.</em>
    </p>

    <p v-if="descriptors.length">
      <strong>Descriptors:</strong> ({{ descriptors.length }})
      <ImportList
        :list="descriptors"
        type_attr="descriptor"
      />
    </p>
    <p v-else>
      <em>No descriptors found.</em>
    </p>
  </div>
</template>

<script setup>
import ImportList from './ImportList.vue'

const props = defineProps({
  otus: {
    type: Array,
    required: true
  },
  descriptors: {
    type: Array,
    required: true
  }
})
</script>

<style lang="scss" scoped>
  .preview {
    padding: 1em 1.5em;
    border: 1px solid #e5e5e5;
    background-color: #fcfcfc;
    box-shadow: 0 2px 3px 0px #e5e5e5;
    margin-right: 24px;
    margin-bottom: 2em;
  }
</style>