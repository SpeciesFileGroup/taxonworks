<template>
  <table class="table-striped">
    <thead>
      <tr>
        <th>Original</th>
        <th>Match</th>
        <th>Valid name</th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="({ taxon, match }) in list"
        :key="taxon.id"
      >
        <td>{{ match }}</td>
        <td>
          <span v-html="taxon.object_tag" /> {{ taxon.cached_author_year }}
        </td>
        <td v-html="taxon.original_combination" />
      </tr>
    </tbody>
  </table>
</template>

<script setup>
defineProps({
  list: {
    type: Array,
    required: true
  }
})
</script>
