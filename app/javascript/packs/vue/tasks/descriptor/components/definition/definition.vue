<template>
  <div>
    <div class="field">
      <label>Name</label>
      <input
        type="text"
        v-model="name"/>
    </div>
    <div class="field">
      <label>Description</label>
      <textarea v-model="description"></textarea>
    </div>
  </div>
</template>
<script>
export default {
  data() {
    return {
      name: undefined,
      description: undefined
    }
  }
}
</script>