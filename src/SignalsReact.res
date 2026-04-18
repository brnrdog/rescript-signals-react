open Signals

let useSignalValue = (signal: Signal.t<'a>): 'a => {
  let subscribe = React.useCallback1((listener: unit => unit) => {
    let firstRun = ref(true)
    let disposer = Effect.runWithDisposer(() => {
      let _ = Signal.get(signal)
      if firstRun.contents {
        firstRun := false
      } else {
        listener()
      }
      None
    })
    () => disposer.dispose()
  }, [signal])

  let getSnapshot = React.useCallback1(() => Signal.peek(signal), [signal])

  React.useSyncExternalStore(~subscribe, ~getSnapshot)
}

let useSignal = (init: unit => 'a): ('a, Signal.t<'a>, 'a => unit) => {
  let signalRef = React.useRef(None)
  let signal = switch signalRef.current {
  | Some(s) => s
  | None =>
    let s = Signal.make(init())
    signalRef.current = Some(s)
    s
  }
  let setter = React.useCallback1(next => Signal.set(signal, next), [signal])
  let value = useSignalValue(signal)
  (value, signal, setter)
}

let useComputed = (compute: unit => 'a): 'a => {
  let computed = React.useMemo0(() => Computed.make(compute))
  useSignalValue(computed)
}

let useComputedWithDeps = (compute: unit => 'a, deps: 'deps): 'a => {
  let computed = React.useMemo1(() => Computed.make(compute), [deps])
  useSignalValue(computed)
}

let useSignalEffect = (fn: unit => option<unit => unit>): unit => {
  React.useEffect0(() => {
    let disposer = Effect.runWithDisposer(fn)
    Some(() => disposer.dispose())
  })
}
