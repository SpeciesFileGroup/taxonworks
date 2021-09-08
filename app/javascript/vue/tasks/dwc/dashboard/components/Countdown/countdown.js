class CountDown {
  constructor (startDate, expiredDate, onRender, onComplete) {
    this.setExpiredDate(startDate, expiredDate)

    this.onRender = onRender
    this.onComplete = onComplete
    this.isPaused = false
  }

  parseDate (date) {
    return date instanceof Date
      ? date
      : new Date(date)
  }

  setExpiredDate (startDate, expiredDate) {
    const currentTime = this.parseDate(startDate).getTime()

    clearInterval(this.intervalId)
    this.timeRemaining = this.parseDate(expiredDate).getTime() - currentTime

    this.timeRemaining <= 0
      ? this.complete()
      : this.start()
  }

  complete () {
    if (typeof this.onComplete === 'function') {
      this.onComplete()
    }
  }

  getTime () {
    return {
      days: Math.floor(this.timeRemaining / 1000 / 60 / 60 / 24),
      hours: Math.floor(this.timeRemaining / 1000 / 60 / 60) % 24,
      minutes: Math.floor(this.timeRemaining / 1000 / 60) % 60,
      seconds: Math.floor(this.timeRemaining / 1000) % 60
    }
  }

  update () {
    if (typeof this.onRender === 'function') {
      this.onRender(this.getTime())
    }
  }

  start () {
    this.update()

    this.intervalId = setInterval(() => {
      if (!this.isPaused) {
        this.timeRemaining -= 1000

        if (this.timeRemaining < 0) {
          this.complete()
          clearInterval(this.intervalId)
        } else {
          this.update()
        }
      }
    }, 1000)
  }

  stop () {
    this.timeRemaining = -1
  }

  pause () {
    this.isPaused = true
  }
}

export default CountDown
