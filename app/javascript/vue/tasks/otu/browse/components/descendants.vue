<template>
  <section-panel
    :spinner="isLoading"
    title="Descendants"
    @menu="showModal = true">
    <a name="descendants"/>
    <ul class="no_bullets">
      <template v-for="(child, index) in childOfCurrentName">
        <li
          v-if="child.id !== otu.taxon_name_id && (index <= max || showAll)"
          :key="child.id">
          <span v-html="child.object_tag"/>
        </li>
      </template>
    </ul>
    <template v-if="childOfCurrentName.length > max">
      <a
        class="cursor-pointer"
        @click="showAll = !showAll">{{ showAll ? 'Show less' : 'Show more' }}</a>
    </template>
    <modal-component
      v-if="showModal"
      @close="showModal = false">
      <h3 slot="header">Filter</h3>
      <div slot="body">
        <label>
          <input
            v-model="onlyChildrens"
            type="checkbox">
          Show only childs
        </label>
      </div>
    </modal-component>
  </section-panel>
</template>

<script>

import AjaxCall from 'helpers/ajaxCall'
import SectionPanel from './shared/sectionPanel'
import ModalComponent from 'components/modal'

export default {
  components: {
    SectionPanel,
    ModalComponent
  },
  props: {
    otu: {
      type: Object,
      required: true
    }
  },
  computed: {
    childOfCurrentName () {
      return (this.onlyChildrens ? this.childs.filter(child => { return this.otu.taxon_name_id === child.parent_id }) : this.childs).sort(function (a, b) {
        if (a.cached > b.cached) {
          return 1
        }
        if (b.cached > a.cached) {
          return -1
        }
        return 0
      })
    }
  },
  data () {
    return {
      onlyChildrens: true,
      childs: [],
      max: 10,
      showAll: false,
      isLoading: false,
      showModal: false
    }
  },
  watch: {
    otu: {
      handler (newVal) {
        this.isLoading = true
        AjaxCall('get', `/taxon_names.json?taxon_name_id[]=${newVal.taxon_name_id}&descendants=true`).then(response => {
          this.childs = response.body
          this.isLoading = false
        })
      },
      immediate: true
    }
  },
  methods: {

  }
}
</script>

<style>

</style>