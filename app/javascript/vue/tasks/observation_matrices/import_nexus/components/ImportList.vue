<template>
  <template
    v-for="(x, i) in list"
    :key="x.name ? x.name : x[type_attr].id"
  >
    <template v-if="x.name">
      {{ x.name }}
    </template>
    <a
      v-else
      :href="x[type_attr].object_url"
      target="_blank"
      v-html="x[type_attr].object_tag"
    />
    <template v-if="i < list.length - 1">, </template>
  </template>
</template>

<script setup>
const props = defineProps({
  list: {
    type: Array,
    required: true
  },
  type_attr: {
    type: String,
    required: true
  }
})
</script>