<template>
  <div>
    <span
      @click="$emit('changed')"
      data-icon="contract"
      v-if="expanded"/>
    <span
      @click="$emit('changed')"
      data-icon="expand"
      v-else/>
  </div>
</template>
<script>

export default {
  props: {
    expanded: {
      type: Boolean,
      default: true
    }
  }
}
</script>
