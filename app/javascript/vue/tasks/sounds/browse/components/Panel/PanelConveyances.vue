<template>
  <div class="panel content">
    <h3>Conveyances</h3>

    <table>
      <thead>
        <tr>
          <td>Label</td>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="conveyance in conveyances"
          :key="conveyance.id"
        >
          <td v-html="conveyance.object_tag" />
        </tr>
      </tbody>
    </table>
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
