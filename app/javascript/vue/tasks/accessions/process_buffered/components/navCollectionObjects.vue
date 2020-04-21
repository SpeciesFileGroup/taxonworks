<template>
  <fieldset
    v-if="Object.keys(coObjects).length">
    <legend>Navigate</legend>
    <div class="horizontal-left-content">
      <template v-for="depic in coObjects.before">
        <a
          class="separate-right"
          v-if="depic.sqed_depiction.hasOwnProperty('image_sections')"
          :key="depic.id"
          :href="coUrl(depic)">
          <img
            class="depiction-box"
            :src="getPrimaryImage(depic).small_image">
        </a>
      </template>
      <a
        class="separate-right"
        :href="coUrl(coObjects.current)"
        v-if="coObjects.current.sqed_depiction.hasOwnProperty('image_sections')">
        <img
          class="depiction-selected"
          :src="getPrimaryImage(coObjects.current).small_image">
      </a>
      <template v-for="depic in coObjects.after">
        <a
          class="separate-right"
          v-if="depic.sqed_depiction.hasOwnProperty('image_sections')"
          :key="depic.id"
          :href="coUrl(depic)">
          <img
            class="depiction-box"
            :src="getPrimaryImage(depic).small_image">
        </a>
      </template>
    </div>
  </fieldset>
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
