<template>
    <form class="content">
        <h3 class="subtitle">Basic information</h3><br>
        <div class="field separate-top">
	        <label>Parent</label>
	        <parent-picker></parent-picker>
        </div>
        <div class="field">
        	<label>Name</label><br>
        	<taxon-name></taxon-name>
        </div>
        <rank-selector></rank-selector>
        <button class="button">Create</button>
      </form>
</template>

<script>
  var parentPicker = require('./parentPicker.vue');
  var taxonName = require('./taxonName.vue');
  var rankSelector = require('./rankSelector.vue');
	export default {
		components: {
			parentPicker,
			taxonName,
			rankSelector
		}
	}
</script>