<template>
  <div>
    <h2>Attributes (predicates) to include</h2>
    <ul>
      <li
        v-for="item in list"
        :key="item.id">
        <label>
          <input type="checkbox">
          {{ item.label }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  data() {
    return {
      list: []
    }
  }
}
</script>
