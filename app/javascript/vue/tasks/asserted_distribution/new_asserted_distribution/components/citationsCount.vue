<template>
  <span>
    <div
      v-if="citations.length"
      class="citation-count"
      @click.prevent="setModalView(true)">
      <span class="circle-button btn-citation button-default">
        <span class="circle-count button-data middle">{{ citations.length }} </span>
      </span>
    </div>
    <modal-component
      v-if="showCitations"
      @close="setModalView(false)">
      <h3 slot="header">Citations</h3>
      <div
        slot="body">
        <display-list
          :list="citations"
          :validations="true"
          :label="['citation_source_body']"
          @delete="removeCitation"
          :edit="false">
          <div
            slot="options"
            slot-scope="slotProps">
            <a
              :title="slotProps.item.source.object_tag"
              class="button-default circle-button btn-citation"
              :href="`/tasks/nomenclature/by_source?source_id=${slotProps.item.source.id}`"
              target="blank"/>
          </div>
        </display-list>
      </div>
    </modal-component>
  </span>
</template>

<script>

import DisplayList from 'components/displayList'
import ModalComponent from 'components/ui/Modal'

export default {
  components: {
    DisplayList,
    ModalComponent
  },
  props: {
    citations: {
      type: Array,
      required: true
    },
  },
  data () {
    return {
      showCitations: false
    }
  },
  methods: {
    setModalView (value) {
      this.showCitations = value
    }
  }
}
</script>
