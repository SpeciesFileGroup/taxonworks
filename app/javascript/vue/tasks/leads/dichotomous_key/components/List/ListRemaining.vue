<template>
  <div class="content">
    <div class="flex-separate middle">
      <h3>Remaining ({{ list.length }})</h3>
      <ListRemainingOptions :list="list" />
    </div>
    <ul>
      <li
        v-for="item in list"
        :key="item.id"
        v-html="item.object_tag"
      />
    </ul>
  </div>
</template>

<script setup>
import ListRemainingOptions from './ListRemainingOptions.vue'

const props = defineProps({
  list: {
    type: Array,
    required: true
  }
})
</script>
