export default function setLoading(bool) {
  if (bool == true) {
    this.loadingCount += 1
    this.loading = true
  } else {
    this.loadingCount -= 1
    if (this.loadingCount == 0) {
      this.loading = false
    }
  }
}