<template>
  <div class="panel header-bar separate-bottom">
    <div class="container content">
    <ul class="breadcrumb_list">
        <li class="breadcrumb_item"><a href="/tasks/nomenclature/browse?taxon_name_id=1">Root</a></li>
        <li class="breadcrumb_item"><a href="/tasks/nomenclature/browse?taxon_name_id=542432">Animalia</a></li>
        <li class="breadcrumb_item"><a href="/tasks/nomenclature/browse?taxon_name_id=542433">Acanthocephala</a></li>
        <li class="breadcrumb_item"><a href="/tasks/nomenclature/browse?taxon_name_id=542434">Archiacanthocephala</a></li>
      <li class="breadcrumb_item current_breadcrumb_position">Oligacanthorhynchida</li></ul>
      <div class="horizontal-left-content middle">
        <h1
          v-html="otu.object_tag"/>
        <radial-annotator
          :global-id="otu.global_id"
          type="annotations"/>
      </div>
      <ul class="context-menu no_bullets">
        <li v-for="item in menu">
          <a>{{item}}</a>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>

import RadialAnnotator from 'components/annotator/annotator'

export default {
  components: {
    RadialAnnotator
  },
  props: {
    otu: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      menu: ['Classification', 'Links', 'Distribution', 'Classification', 'Citations', 'Gallery', 'Specimen records', 'Type information']
    }
  }
}
</script>

<style lang="scss" scoped>
  .header-bar {
    margin-left: -15px;
    margin-right: -15px;
  }
  .container {
    margin: 0 auto;
    width:1240px;
  }
  .breadcrumb_list {
    margin-bottom: 32px;
  }
</style>