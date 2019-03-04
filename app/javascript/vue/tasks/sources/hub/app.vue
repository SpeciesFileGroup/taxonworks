<template>
  <div>
    <h1>Task: Source hub</h1>
    <div>
      <search-component />
      <new-component />
      <metadata-component />
    </div>
    <recent-component />
  </div>
</template>

<script>

import NewComponent from './components/new'
import RecentComponent from './components/recent'
import MetadataComponent from './components/metadata'
import SearchComponent from './components/search'

export default {
  components: {
    NewComponent,
    RecentComponent,
    MetadataComponent,
    SearchComponent
  }
}
</script>

<style lang="scss" >
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
</style>