export default (data) => {
  const message = data.async
    ? `${data.total_attempted} collecting events queued for updating.`
    : `${data.updated.length} collection events were successfully updated.`

  TW.workbench.alert.create(message, 'notice')
}
