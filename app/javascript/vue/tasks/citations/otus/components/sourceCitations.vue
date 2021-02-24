<template>
  <div
    v-if="items.length"
    class="slide-panel-category">
    <div class="slide-panel-category-header">OTU</div>
    <ul class="slide-panel-category-content">
      <li
        v-for="item in items"
        @click="setOtu(item)"
        class="flex-separate middle slide-panel-category-item">
        <span v-html="item.citation_object.object_tag"/>
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
      items() {
        return this.$store.getters[GetterNames.GetSourceCitationsList]
      }
    },
    methods: {
      removeCitation(item) {
        AjaxCall('delete', '/citations/' + item.id).then(() => {
          this.$store.commit(MutationNames.RemoveSourceFormCitationList, item.id)
          this.$store.commit(MutationNames.RemoveOtuFormCitationList, item.id)
        })
      },
      setOtu(item) {
        AjaxCall('get', `/otus/${item.citation_object_id}.json`).then(response => {
          this.$store.commit(MutationNames.SetOtuSelected, response.body)
        })
      }
    }
  }
</script>
