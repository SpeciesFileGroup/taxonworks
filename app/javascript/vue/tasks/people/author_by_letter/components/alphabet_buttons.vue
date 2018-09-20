<template>
  <div>
    <table>
      <tr>
        <td v-for="letter in alphabet1"
            @click="sendLetter(letter)">{{ letter }}
        </td>
      </tr>
      <tr>
        <td v-for="letter in alphabet2"
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
        alphabet1: "ABCDEFGHIJKLM".split(""),
        alphabet2: "NOPQRSTUVWXYZ".split(""),
        alphabet: "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split(""),

      }
    },
    methods: {
      sendLetter(letter) {
        this.$emit("keypress", letter);
      }
    }
  }
</script>