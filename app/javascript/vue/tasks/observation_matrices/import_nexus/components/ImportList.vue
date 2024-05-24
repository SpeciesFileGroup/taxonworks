<template>
  <template
    v-for="(x, i) in list"
    :key="x.name ? x.name : x[typeAttr].id"
  >
    <template v-if="x.name">
      {{ x.name }}
    </template>
    <a
      v-else
      :href="x[typeAttr].object_url"
      target="_blank"
      v-html="x[typeAttr].object_tag"
    />
    <span v-if="i < list.length - 1" class="comma">, </span>
  </template>
</template>

<script setup>
const props = defineProps({
  list: {
    type: Array,
    required: true
  },
  typeAttr: {
    type: String,
    required: true
  }
})
</script>

<style lang="scss" scoped>
.comma {
  margin-right: 1em;
}
</style>