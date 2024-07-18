<template>
  <table class="table-striped full_width">
    <thead>
      <tr>
        <th class="w-2"></th>
        <th class="w-2">Merged</th>
        <th class="w-2">Unmerged</th>
        <th>Errors</th>
      </tr>
    </thead>
    <tbody>
      <template
        v-for="({ merged, unmerged, errors }, key) in response"
        :key="key"
      >
        <tr>
          <td>{{ key }}</td>
          <td>{{ merged }}</td>
          <td>{{ unmerged }}</td>
          <td>
            <div v-if="errors">
              <ul class="no_bullets">
                <li
                  v-for="error in errors"
                  :key="error.message"
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
