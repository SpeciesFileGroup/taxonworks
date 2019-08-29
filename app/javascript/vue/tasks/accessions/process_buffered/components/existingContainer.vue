<template>
  <div>
    <ul class="table-entrys-list">
      <li
        v-for="item in list"
        class="list-complete-item middle"
        :key="item.id">
        <span v-html="item.object_tag" />
        <div class="horizontal-left-content separate-left">
          <button
            v-if="item.id == collectingEvent.id"
            type="button"
            class="button normal-input button-default separate-right"
            disabled>Current
          </button>
          <button
            v-else
            type="button"
            class="button normal-input button-default separate-right"
            @click="collectingEvent = item">Select
          </button>
          <view-ce :collecting-event="item" />
        </div>
      </li>
    </ul>
  </div>
</template>

<script>

import { GetCollectingEventsFilter } from '../request/resource'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import ViewCe from './viewCE'

export default {
  components: {
    ViewCe
  },
  computed: {
    collectingEvent: {
      get () {
        return this.$store.getters[GetterNames.GetCollectingEvent]
      },
      set (value) {
        console.log(value)
        this.$store.commit(MutationNames.SetCollectingEvent, value)
      }
    },
    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    }
  },
  data () {
    return {
      list: [],
      timeout: undefined
    }
  },
  watch: {
    collectingEvent: {
      handler (newVal) {
        const params = {
          in_verbatim_locality: newVal.verbatim_locality ? newVal.verbatim_locality : undefined
        }
        clearTimeout(this.timeout)
        this.timeout = setTimeout(this.getList, 2000, params)
      },
      deep: true
    }
  },
  methods: {
    getList (params) {
      GetCollectingEventsFilter(params).then(response => {
        this.list = response.body
        this.$emit('search', this.list)
      })
    }
  }
}
</script>
