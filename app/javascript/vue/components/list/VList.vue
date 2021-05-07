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
    overflow-y: scroll;
    padding: 0px;
    position: relative;

    li {
      margin: 0px;
      padding: 6px;
      border: 0px;
      border-top: 1px solid #f5f5f5;
    }
  }
</style>
