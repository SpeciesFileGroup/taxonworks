<template>
  <div class="panel content">
    <h2>Health</h2>
    <table>
      <tbody>
        <tr
          v-for="(value, label) in health"
          :key="label">
          <td>{{ label }}</td>
          <td>{{ printValue(value) }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>

import { inject, computed } from 'vue'

const useState = inject('state')
const health = computed(() => useState.metadata?.health)

const printValue = value => {
  if (typeof value === 'boolean') {
    return value
      ? '✅'
      : '❌'
  }

  return value
}

</script>
