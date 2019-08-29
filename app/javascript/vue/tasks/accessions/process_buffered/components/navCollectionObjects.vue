<template>
  <div
    class="horizontal-left-content"
    v-if="Object.keys(coObjects).length">
    <a
      class="separate-right"
      v-for="depic in coObjects.before"
      :key="depic.id"
      :href="coUrl(depic)">
      <img
        class="depiction-box"
        :src="getPrimaryImage(depic).small_image">
    </a>
    <a
      class="separate-right"
      :href="coUrl(coObjects.current)">
      <img
        class="depiction-selected"
        :src="getPrimaryImage(coObjects.current).small_image">
    </a>
    <a
      class="separate-right"
      v-for="depic in coObjects.after"
      :key="depic.id"
      :href="coUrl(depic)">
      <img
        class="depiction-box"
        :src="getPrimaryImage(depic).small_image">
    </a>
  </div>
</template>

<script>
export default {
  props: {
    coObjects: {
      type: Object,
      default: () => { return {} }
    }
  },
  methods: {
    coUrl (depic) {
      return `/tasks/accessions/process_buffered/index?collection_object_id=${depic.depiction_object_id}`
    },
    getPrimaryImage (depiction) {
      const sqed = depiction.sqed_depiction
      return sqed.image_sections[Object.values(sqed.metadata_map).findIndex(item => { return item === sqed.primary_image })]
    }
  }
}

</script>

<style scoped>
  .depiction-box {
    max-height: 80px;
    height: auto;
    border:1px solid transparent;
  }
  .depiction-selected {
    max-height: 100px;
    border:1px solid black;
    height: auto;
  }
</style>
