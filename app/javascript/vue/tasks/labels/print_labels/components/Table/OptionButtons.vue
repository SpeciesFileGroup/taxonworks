<template>
  <div>
    <button
      type="button"
      class="button normal-input button-default"
      @click="$emit('selectAll', true)">
      Select all
    </button>
    <button
      type="button"
      class="button normal-input button-default"
      @click="$emit('selectMyLabels', true)">
      Select my labels
    </button>
    <button
      type="button"
      class="button normal-input button-delete"
      @click="$emit('destroyAll', true)">
      Destroy all
    </button>
  </div>
</template>

<script>
export default {

}
</script>

