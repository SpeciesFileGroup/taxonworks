<template>
  <div class="panel content">
    <h3>Conveyances</h3>

    <ul>
      <li
        v-for="conveyance in conveyances"
        :key="conveyance.id"
      >
        <span v-html="conveyance.object_tag" />
      </li>
    </ul>
  </div>
</template>

<script setup>
defineProps({
  conveyances: {
    type: Array,
    default: () => []
  }
})
</script>
