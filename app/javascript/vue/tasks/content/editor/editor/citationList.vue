<template>
  <div v-if="activeCitations && content && citations.length > 0">
    <ul>
      <li
        class="flex-separate middle"
        v-for="(item, index) in citations">{{ item.source.author_year }}
        <div
          @click="removeItem(index, item)"
          class="circle-button btn-delete">Remove
        </div>
      </li>
    </ul>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import AjaxCall from 'helpers/ajaxCall'

export default {
  computed: {
    citations () {
      return this.$store.getters[GetterNames.GetCitationsList]
    },
    content () {
      return this.$store.getters[GetterNames.GetContentSelected]
    },
    activeCitations () {
      return this.$store.getters[GetterNames.PanelCitations]
    }
  },
  watch: {
    content (val, oldVal) {
      if (val != undefined) {
        if (JSON.stringify(val) !== JSON.stringify(oldVal)) {
          this.loadContent()
        }
      } else {
        this.$store.commit(MutationNames.SetCitationList, [])
      }
    }
  },
  methods: {
    removeItem: function (index, item) {
      AjaxCall('delete', '/citations/' + item.id).then(() => {
        this.$store.commit(MutationNames.RemoveCitation, index)
      })
    },
    loadContent: function () {
      let ajaxUrl

      ajaxUrl = `/contents/${this.content.id}/citations`
      AjaxCall('get', ajaxUrl, this.content).then(response => {
        this.$store.commit(MutationNames.SetCitationList, response.body)
      })
    }
  }
}
</script>
