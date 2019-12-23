<template>
  <section-panel
    :spinner="isLoading"
    title="Descendants">
    <a name="descendants"/>
    <ul class="no_bullets">
      <template v-for="(child, index) in childs">
        <li
          v-if="child.id !== otu.taxon_name_id && (index <= max || showAll)"
          :key="child.id">
          <span v-html="child.object_tag"/>
        </li>
      </template>
    </ul>
    <template v-if="childs.length > max">
      <a
        class="cursor-pointer"
        @click="showAll = !showAll">{{ showAll ? 'Show less' : 'Show more' }}</a>
    </template>
  </section-panel>
</template>

<script>

import AjaxCall from 'helpers/ajaxCall'
import SectionPanel from './shared/sectionPanel'

export default {
  components: {
    SectionPanel
  },
  props: {
    otu: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      childs: [],
      max: 10,
      showAll: false,
      isLoading: false
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