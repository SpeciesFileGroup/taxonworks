<template>
  <div class="panel content">
    <h3>Eliminated ({{ list.length }})</h3>
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
const props = defineProps({
  list: {
    type: Array,
    required: true
  }
})
</script>
