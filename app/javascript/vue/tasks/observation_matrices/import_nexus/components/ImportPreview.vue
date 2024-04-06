<template>
  <div
    v-if="otus.length"
    class="preview"
  >
    <em> Linked characters or OTUs are matches with existing data. </em>

    <p><strong>Taxa:</strong> ({{ otus.length }})
      <template
        v-for="(x, i) in otus"
        :key="x.name ? x.name : x.otu.id"
      >
        <template v-if="x.name">
          {{ x.name }}
        </template>
        <a
          v-else
          :href="x.otu.object_url"
          target="_blank"
          v-html="x.otu.object_tag"
        />
        <template v-if="i < otus.length - 1">, </template>
      </template>
    </p>
  </div>
</template>

<script setup>

const props = defineProps({
  otus: {
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