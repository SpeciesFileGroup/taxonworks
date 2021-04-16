<template>
  <div>
    <div
      v-for="(item, gid) in keywords"
      :key="gid"
    >
      <hr>
      <p>
        <b v-html="item.object.object_tag" />
      </p>

      <template v-for="(object, key) in item.totals">
        <div
          v-if="object"
          class="tag_list"
          :key="key"
        >
          <span class="capitalize tag_label">{{ key }}</span>
          <span class="tag_total">{{ object }}</span>

          <template v-if="key !== 'total'">
            <button
              type="button"
              class="button normal-input button-submit"
              @click="batchLoad(key, item.object.id, object)"
            >
              Create
            </button>
            <button
              type="button"
              class="separate-left button normal-input button-delete"
              @click="removeKeyword(item.object.id, key)"
            >
              Remove
            </button>
          </template>

          <button
            v-if="!isOneRow(item) && key === 'total'"
            class="button normal-input button-submit">
            Create for both
          </button>
        </div>
      </template>
    </div>
  </div>
</template>

<script>

import { MutationNames } from '../store/mutations/mutations'
import { batchRemoveKeyword } from '../request/resources'
import Batch from './mixins/batch'

export default {
  name: 'CreateTag',

  mixins: [Batch],

  data () {
    return {
      batchType: 'tags',
      metadataList: 'keywords'
    }
  },

  methods: {
    removeKeyword (id, type) {
      this.$store.commit(MutationNames.SetSaving, true)
      batchRemoveKeyword(id, type).then(async () => {
        this.getMeta()
        this.$store.commit(MutationNames.SetSaving, false)
      })
    },

    isOneRow ({ totals }) {
      return Object.entries(totals).filter(([k, v]) => k !== 'total' && v > 0).length === 1
    }
  }
}
</script>
