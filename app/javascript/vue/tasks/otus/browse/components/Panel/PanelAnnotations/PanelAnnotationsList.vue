<template>
  <div>
    <h5 class="annotation-group-title">{{ title }}</h5>
    <ul class="annotation-group-list">
      <li
        v-for="item in list"
        :key="item.id"
      >
        <span v-html="item.object_tag" />
      </li>
    </ul>
  </div>
</template>

<script setup>
defineProps({
  list: {
    type: Array,
    required: true
  },

  title: {
    type: String,
    required: true
  }
})
</script>

<style lang="scss" scoped>
.annotation-group-title {
  margin: 0 0 var(--spacing-xs);
  font-size: var(--font-size-sm);
  font-weight: 600;
}

.annotation-group-list {
  margin: 0;
  padding-left: var(--spacing-md);

  li {
    line-height: 1.5;
  }
}
</style>
