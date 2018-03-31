<template>
  <div>
    <div v-for="(item) in keywords">
      <hr>
      <b><p v-html="item.object.object_tag"/></b>
      <div
        class="tag_list"
        v-for="(object, key) in item.totals"
        v-if="object">
        <div class="capitalize tag_label">{{ key }}</div>
        <div class="tag_total">{{ object }}</div>
        <button
          class="button normal-input button-submit"
          type="button"
          @click="batchLoad(key, item.object.id, 'tags', object)">Create
        </button>
        <button
          v-if="key != 'total'"
          class="separate-left button normal-input button-delete"
          type="button"
          @click="removeKeyword(item.object.id, key)">Remove
        </button>
      </div>
    </div>
  </div>
</template>
<script>
export default {

}
</script>