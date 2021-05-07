<template>
  <li
    class="list-complete-item"
    :class="{ 'highlight': checkHighlight(item) }">
    <slot/>
  </li>
</template>
<script>

export default {
  props: {
    highlight: {
      type: Boolean,
      default: false
    }
  }
}
</script>
<style lang="scss" scoped>

  .highlight {
    background-color: #E3E8E3;
  }

  .list-complete-item {
    justify-content: space-between;
    transition: all 0.5s, opacity 0.2s;
  }

  .list-complete-enter, .list-complete-leave-to {
    opacity: 0;
    font-size: 0px;
    border: none;
    transform: scale(0.0);
  }

  .list-complete-leave-active {
    width: 100%;
    position: absolute;
  }
</style>
