<template>
  <div>
    <template v-for="(object, key) in keywords.totals">
      <div
        class="tag_list"
        v-if="object"
        :key="key"
      >
        <div class="capitalize tag_label">
          {{ key }}
        </div>
        <div class="tag_total">
          {{ object }}
        </div>
        <button
          class="button normal-input button-submit"
          type="button"
          @click="batchLoad(key, undefined, object)"
        >
          Create
        </button>
      </div>
    </template>
  </div>
</template>

<script>

import Batch from './mixins/batch'

export default {
  name: 'CreatePinboard',
  mixins: [Batch],

  data () {
    return {
      batchType: 'pinboard',
      metadataList: 'pinboard'
    }
  }
}
</script>
