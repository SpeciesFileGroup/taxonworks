export function makeNotificationWhenPromisesEnd(promises) {
  const handlePromises = Promise.allSettled(promises)

  handlePromises.then((res) => {
    const resolvedCount = res.filter((r) => r.status === 'fulfilled').length
    const rejectedCount = (promises.length = resolvedCount)

    const message = rejectedCount.length
      ? `${resolvedCount} record(s) were successfully saved. ${rejectedCount} were not saved`
      : `${resolvedCount} record(s) were successfully saved`

    TW.workbench.alert.create(message)
  })

  return handlePromises
}
