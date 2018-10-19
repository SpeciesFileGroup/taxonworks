<template>
  <div>
    <table>
      <tr
        v-for="(row, index) in rows"
        :key="index">
        <td
          v-for="letter in row"
          :key="letter"
          :class="{ 'selected-letter': (letter == selected) }"
          @click="sendLetter(letter)">{{ letter }}
        </td>
      </tr>
    </table>
  </div>
</template>
<script>
  export default {
    data() {
      return {
        rows: {
          alphabet1: "ABCDEFGHIJKLM".split(""),
          alphabet2: "NOPQRSTUVWXYZ".split("")
        },
        selected: ''
      }
    },
    methods: {
      sendLetter(letter) {
        this.setSelectedLetter(letter)
        this.$emit("keypress", letter);
      },
      setSelectedLetter(letter) {
        this.selected = letter
      }
    }
  }
</script>

<style scoped>
  .selected-letter {
    color: #FFF;
    background-color: #E3E8E3;
  }
</style>