<template>
  <div>
    <div
      class="tag_list"
      v-for="(object, key) in pinboard.totals"
      v-if="object">
      <div class="capitalize tag_label">{{ key }}</div>
      <div class="tag_total"> {{ object }}</div>
      <button
        class="button normal-input button-submit"
        type="button"
        @click="batchLoad(key, undefined, 'pinboard', object)">Create
      </button>
    </div>
  </div>
</template>

<script>
export default {
  
}
</script>