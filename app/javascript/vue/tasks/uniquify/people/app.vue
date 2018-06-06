<template>
  <div>
    <div class="flex-separate middle">
      <h1>Uniquify people</h1>
      <span
          @click="resetApp"
          class="reload-app"
          data-icon="reset">Reset
      </span>
    </div>
    <spinner
        v-if="isLoading"
        :full-screen="true"
        legend="Loading..."
        :logo-size="{ width: '100px', height: '100px'}"/>
    <div class="flexbox">
      <div class="last_name separate-right">
        <h2>:ast Name</h2>
        <last_name v-model="filter.last_name"/>
      </div>
      <div class="first_name separate-right separate-left">
        <h2>First Name</h2>
        <first-name
            v-model="filter.first_name"
            :first-name="filter.first_name"/>
      </div>
      <div class="role_types separate-right separate-left">
        <h2>Roles</h2>
        <role_types
            v-model="filter.selected_for"
            :select-options-url="filter.annotation_type.select_options_url"
            :all-select-option-url="filter.annotation_type.all_select_option_url"
            :on-model="filter.model"
            @selected_for="filter.selected_for = $event"/>
      </div>
      <div class="found_names separate-right separate-left">
        <h2>Select person</h2>
        <found-people v-model="filter.found_people"/>
      </div>
      <div class="match_names separate-right separate-left">
        <h2>Match people</h2>
        <match-people v-model="filter.match_people"/>
      </div>
    </div>
    <button
        class="button normal-input button-default"
        @click="processResult"
        :disabled="submitAvailable"
        type="submit">Submit
    </button>
    <request-bar
        :url="request.url"
        :total="request.total"/>
    <view-list
        :list="resultList"/>
  </div>
</template>

<script>
  import LastName from './components/last_name'
  import FirstName from './components/first_name'
  import RoleTypes from './components/role_types'
  import FoundNames from './components/found_names'
  import MatchNames from './components/match_names'
</script>