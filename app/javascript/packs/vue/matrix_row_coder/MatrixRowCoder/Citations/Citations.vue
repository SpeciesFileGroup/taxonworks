<template>
  <div class="citations">
    <div class="citations__header">Citations</div>
    <ul class="citations__list">
      <li
        class="citations__item"
        v-for="citation in citations">

        <div class="citations__description">{{ citation.description }}</div>
        <div class="citations__author">{{ citation.author }}</div>
      </li>
    </ul>
  </div>
</template>

<style src="./Citations.styl" lang="stylus"></style>

<script>
export default {
  name: 'Citations',
  props: ['citations']
}
</script>
