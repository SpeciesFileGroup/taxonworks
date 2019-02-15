<template>
  <div>
    <h3>Mode</h3>
    <ul class="no_bullets">
      <li>
        <label>
          <input 
            type="radio"
            :value="true"
            name="sqed-mode"
            v-model="newObject"
          >
          New object
        </label>
      </li>
      <li>
        <label>
          <input 
            type="radio"
            name="sqed-mode"
            :value="false"
            v-model="newObject"
          >
          Existing object
        </label>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  data() {
    return {
      newObject: true
    }
  }
}
</script>
