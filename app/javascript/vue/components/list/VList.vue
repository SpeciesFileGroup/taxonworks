<template>
  <transition-group
    class="table-entrys-list"
    name="list-complete"
    tag="ul">
    <slot />
  </transition-group>
</template>
<script>

export default {}

</script>

<style lang="scss" scoped>
  .table-entrys-list {
    padding: 0px;
    position: relative;

    li {
      margin: 0px;
      padding: 1em 0;
      border: 0px;
      border-bottom: 1px solid #f5f5f5;
    }
  }
</style>
