<template>
  <div>
    <h4><b>{{ title }}</b></h4>
    <ul>
      <li
        v-for="item in list"
        :key="item.id">
        <span v-html="item.object_tag"/>
      </li>
    </ul>
  </div>
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
