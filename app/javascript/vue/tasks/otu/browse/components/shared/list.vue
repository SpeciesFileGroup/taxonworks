<template>
  <ul class="no_bullets">
    <h4><b>{{ title }}</b></h4>
    <li
      v-for="item in list"
      :key="item.id">
      <span v-html="item.object_tag"/>
    </li>
  </ul>
</template>

<script>
export default {
  props: {
    list: {
      type: Array,
      required: true
    },
    title: {
      type: String,
      required: true
    }
  }
}
</script>
