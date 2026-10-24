// Session recovery and profile reads may never settle on a suspended mobile tab
// or a broken network. Always leave a usable retry screen, without discarding
// the stored session or accepting a result from a timed-out attempt.
export function withStartupDeadline<T>(operation: PromiseLike<T>, timeoutMs = 15000): Promise<T> {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error('Le chargement de ton espace a expiré.')), timeoutMs)
    Promise.resolve(operation).then(
      value => { clearTimeout(timer); resolve(value) },
      error => { clearTimeout(timer); reject(error) },
    )
  })
}
