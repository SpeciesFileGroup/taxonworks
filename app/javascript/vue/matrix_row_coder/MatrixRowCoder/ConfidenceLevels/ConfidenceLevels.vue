<template>
  <div class="confidence-levels">
    <div>Confidences</div>
    <ul class="confidence-levels__list">
      <li class="confidence-levels__confidence-level" v-for="confidenceLevel in confidences">
        <label class="confidence-levels__checkbox-label" :style="{ borderColor: confidenceLevel.color }">
          <span class="confidence-levels__checkbox-label-text">{{ confidenceLevel.name }}</span>
          <input
            type="checkbox"
            v-model="confidenceLevel.isChecked">
        </label>
      </li>
    </ul>
  </div>
</template>

<style src="./ConfidenceLevels.styl" lang="stylus"></style>

<script>
export default {
  name: 'ConfidenceLevels',
  props: ['confidences']
}
</script>
