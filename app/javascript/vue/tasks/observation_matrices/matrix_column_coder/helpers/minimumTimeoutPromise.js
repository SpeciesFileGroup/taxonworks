export default function minimumTimeoutPromise (promise, duration = 1) {
  const timeoutPromise = new Promise(resolve => {
    setTimeout(_ => {
      resolve(true)
    }, duration)
  })

  return Promise.all([promise, timeoutPromise])
    .then(results => {
      const [promiseData, timeoutPromiseData] = results
      return promiseData
    })
};
