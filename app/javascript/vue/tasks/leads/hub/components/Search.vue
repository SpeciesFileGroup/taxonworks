<template>
  <h3 class="title-section">Search</h3>
  <div class="panel content card-new">
    <Autocomplete
      url="/leads/autocomplete"
      param="term"
      label="label_html"
      @getItem="loadLead"
      placeholder="Search keys"
    />
  </div>
</template>

<script setup>
import Autocomplete from '@/components/ui/Autocomplete'

function loadLead(lead) {
  window.open(`/leads/${lead.id}`, '_self')
}
</script>

<style lang="scss" scoped>
.card-new {
  width: 250px;
  margin-bottom: 8px;
  margin-right: 8px;
  text-decoration: none;
  align-items: middle;
}
</style>
