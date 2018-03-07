<template>
  <div class="depictions">
    <div class="depictions__header">Depictions</div>
    <div v-if="depictions.length == 0">
      No depictions
    </div>
    <ul class="depictions__images" v-if="depictions.length > 0">
      <li class="depictions__image-container" v-for="depiction in depictions">
        <img
          :src="depiction.thumbSrc"
          :alt="depiction.alt">
      </li>
    </ul>
  </div>
</template>

<style src="./Depictions.styl" lang="stylus"></style>

<script>
export default {
  name: 'Depictions',
  props: ['depictions']
}
</script>
