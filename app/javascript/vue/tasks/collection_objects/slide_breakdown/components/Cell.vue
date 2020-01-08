<template>
  <div
    :style="style">
  </div>
</template>

<script>
export default {
  props: {
    cell: {
      type: Array,
      required: true
    },
    scale: {
      type: Number,
      default: 1
    }
  },
  computed: {
    style() {
      return {
        cursor: pointer,
        position: 'absolute',
        left: `${this.cell[0][0]/this.scale}px`,
        top: `${this.cell[0][1]/this.scale}px`,
        width: `${(this.cell[1][0] - this.cell[0][0])/this.scale}px`,
        height: `${(this.cell[1][1] - this.cell[0][1])/this.scale}px`,
        'background-color': '#444',
        'z-index': 2,
        opacity: 0.2
      }
    }
  }
}
</script>

<style>

</style>