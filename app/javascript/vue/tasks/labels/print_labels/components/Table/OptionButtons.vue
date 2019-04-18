<template>
  <div>
    <button
      type="button"
      class="button normal-input button-default"
      @click="$emit('new', true)">
      Add new label
    </button>
    <button
      type="button"
      class="button normal-input button-default"
      @click="$emit('selectAll', true)">
      Select all
    </button>
    <button
      type="button"
      class="button normal-input button-delete"
      @click="$emit('destroyAll', true)">
      Destroy all selected
    </button>
  </div>
</template>

<script>
export default {

}
</script>

