<template>
  <h1>Dichotomous Keys Hub</h1>
  <div id="leads_hub_components">
    <SearchComponent />
    <NewComponent />
    <KeysList />
  </div>
</template>

<script setup>
import KeysList from './components/KeysList.vue'
import NewComponent from './components/New.vue'
import SearchComponent from './components/Search.vue'
</script>

<style lang="scss">
#leads_hub_components {
  .title-section {
    display: flex;
    height: 34px;
    border-top-right-radius: 3px;
    border-top-left-radius: 3px;
    justify-content: space-between;
    flex-direction: flex-start;
    align-items: center;
    margin-left: 1em;
    margin-right: 1em;
    border-bottom: 1px solid #e5e5e5;
    text-align: center;
    font-size: 13px;
    color: #888;
    text-transform: uppercase;
  }
}
</style>
