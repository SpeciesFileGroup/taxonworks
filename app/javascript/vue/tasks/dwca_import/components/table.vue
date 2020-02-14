<template>
  <table>
    <thead>
      <tr>
      </tr>
    </thead>
    <tbody>
      <row-component/>
    </tbody>
  </table>
</template>

<script>



export default {
  props: {
    list: {
      type: Object,
      required: true
    }
  }
}
</script>

<style>

</style>