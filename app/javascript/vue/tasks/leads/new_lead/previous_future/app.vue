<template>
  <PreviousLeads v-if="store.lead.id" />

  <fieldset
    v-if="store.print_key"
    class="print-key"
  >
    <legend>Key Preview</legend>
    <div v-html="store.print_key" />
  </fieldset>
</template>

<script setup>
import { onBeforeMount, ref } from 'vue'
import { useStore } from '../store/useStore.js'
import PreviousLeads from './components/PreviousLeads.vue'

const store = useStore()

// TODO Currently this is needed (why?) in the lead otu case where we have #id
// links in the v-html'ed html version of the key.
// LLM
onBeforeMount(() => {
  document.addEventListener('click', (e) => {
    const elt = e.target.closest("a[href^='#']");
    if (elt) {
      const id = elt.getAttribute('href').slice(1);
      const target = document.getElementById(id);
      if (target) {
        e.preventDefault(); // prevent full-page reload
        target.scrollIntoView({ behavior: 'smooth' });
      }
    }
  })
})
// END LLM

</script>

<style lang="scss" scoped>

.print-key {
  width: 80vw;
  margin: 0 auto;
  border-top-left-radius: 0.9rem;
  border-bottom-left-radius: 0.9rem;
  padding-left: 2em;
  padding-right: 2em;
  height: 400px;
  overflow-y: scroll;
  margin-bottom: 1.5em;
  box-shadow: rgba(36, 37, 38, 0.08) 4px 4px 15px 0px;
  background-color: #fff;
}
</style>