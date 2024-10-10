<template>
  <table class="table-striped full_width">
    <thead>
      <tr>
        <th class="w-2"></th>
        <th class="w-2">Unified</th>
        <th class="w-2">Not unified</th>
        <th class="w-2">Deduplicated</th>
        <th>Errors</th>
      </tr>
    </thead>
    <tbody>
      <template
        v-for="(
          { merged, unmerged, deduplicated, errors }, key
        ) in response.details"
        :key="key"
      >
        <tr>
          <td>{{ key }}</td>
          <td>{{ merged }}</td>
          <td>{{ unmerged }}</td>
          <td>{{ deduplicated }}</td>
          <td>
            <div v-if="errors">
              <ul class="no_bullets">
                <li
                  v-for="error in errors"
                  :key="error.id"
                  class="text-error-color"
                >
                  {{ error.message }}
                </li>
              </ul>
            </div>
          </td>
        </tr>
      </template>
    </tbody>
  </table>
</template>

<script setup>
defineProps({
  response: {
    type: Object,
    default: () => ({})
  }
})
</script>
