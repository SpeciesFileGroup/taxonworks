export default (data) => {
  const message = data.async
    ? `${data.total_attempted} collection objects queued for updating.`
    : `${data.updated.length} collection objects were successfully updated.`

  TW.workbench.alert.create(message, 'notice')
}
