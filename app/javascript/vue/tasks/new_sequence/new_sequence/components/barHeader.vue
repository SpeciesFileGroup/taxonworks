<template>
  <div>
    <ul class="context-menu">
      <li>
        <label>
          <input
            type="checkbox"
            v-model="primers"
            @change="$emit('query', primers)">
          With primers
        </label>
      </li>
      <li>
        <label>
          <input
            type="checkbox"
            v-model="query"
            @change="$emit('query', query)">
          From query
        </label>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  data() {
    return {
      primers: false,
      query: false
    }
  }
}
</script>
