<template>
  <div
    v-if="citations.length"
    class="citation-count"
    @mouseover="showCitations = true"
    @mouseout="showCitations = false">
    <span class="button-data circle-button btn-citation">
      <span class="circle-count button-default middle">{{ citations.length }} </span>
    </span>
    <div
      @mouseover="showCitations = true"
      @mouseout="showCitations = false"
      v-show="showCitations"
      class="citation-tooltip-list panel">
      <display-list 
        :list="citations"
        label="citation_source_body"
        :remove="false"
        :edit="false">
        <div
          slot="options"
          slot-scope="slotProps">
          <display-source :source="slotProps.item.source"/>
        </div>
      </display-list>
    </div>
  </div>
</template>

<script>

import DisplayList from 'components/displayList'
import DisplaySource from './displaySource'

export default {
  components: {
    DisplayList,
    DisplaySource
  },
  props: {
    citations: {
      type: Array,
      required: true
    },
  },
  data() {
    return {
      showCitations: false,
    }
  }
}
</script>

<style lang="scss">
  .citation-count {
    display: block;
    position: relative;
    width: 34px
  }
  .citation-count-text {
    position: relative;
    font-size: 100%;
    justify-content: center
  }
  .citation-tooltip-list {
    position: absolute;
    min-width: 300px;
    transform: translate(0%, -10%);
    z-index: 30;
  }
  .circle-count {
    right:-2px;
    bottom: -2px;
    justify-content: center;
    position: absolute;
    border-radius: 50%;
    display: flex;
    width: 12px;
    height: 12px;
    min-width: 12px;
    min-height: 12px;
    font-size: 8px;
    box-shadow: 0px 1px 2px 0px #EBEBEB;
    margin: 5px;
    cursor: pointer;
  }
</style>
