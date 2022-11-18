<template>
  <div class="panel content">
    <div>
      <span class="feedback feedback-success feedback-thin">First with data: <a :href="`/tasks/accessions/breakdown/sqed_depiction/${list.navigation.filtered.first_with_data}`">{{ list.navigation.filtered.first_with_data }}</a></span>&nbsp;
      <span class="feedback feedback-warning feedback-thin">First without data: <a :href="`/tasks/accessions/breakdown/sqed_depiction/${list.navigation.filtered.first_without_data}`">{{ list.navigation.filtered.first_without_data }}</a></span>&nbsp;
      <span class="feedback feedback-success feedback-thin">Last with data: <a :href="`/tasks/accessions/breakdown/sqed_depiction/${list.navigation.filtered.last_with_data}`">{{ list.navigation.filtered.last_with_data }}</a></span>&nbsp;
      <span class="feedback feedback-warning feedback-thin">Last without data: <a :href="`/tasks/accessions/breakdown/sqed_depiction/${list.navigation.filtered.last_without_data}`">{{ list.navigation.filtered.last_without_data }}</a></span>&nbsp;
    </div>
    <div class="full_width horizontal-left-content flex-start">
      <h3 v-html="list.svg_legend" />
      <div v-html="list.svg_map" />
    </div>
  </div>
</template>

<script setup>

defineProps({
  list: {
    type: Object,
    default: undefined
  }
})
</script>
